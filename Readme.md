#Docker Exercice - Description

Deploy a loadbalanced ruby application backed by a redis database, using docker.

The diagram: 
``` 
                              +--------------+
                    +--------->              +----------+
                    |         |   RUBY APP   |          |
             +------+-+       |              |     +----v------+
             |        |       +--------------+     |           |
    +-------->   LB   |                            |   REDIS   |
             |        |                            |           |
             +------+-+       +--------------+     +----^------+
                    |         |              |          |
                    |         |   RUBY APP   |          |
                    +--------->              +----------+
                              +--------------+
```
#Architecture solution

The solution choosen comprehends the creation of two docker images, one serving
the redis database and the other the ruby app.

Both images will be uploaded to Docker Hub, under my personal account (lipixx)
and then imported to OpenShift.

In OpenShift we will create a route and set the scale parameter to make the
app load balanced.

#Implementation of the separate components
##Step 1 - REDIS Database

In order to provide a dockerized redis server, we could us the official image 
of REDIS available on DockerHub, but we opted to configure it from scratch.

The alternative is to simply import a minimal image, like the centos one,
and to install and configure the database within that image.

Check the Dockerfile under redis/Dockerfile to see how it is implemented.

###Build&Run REDIS Database container

To build and test it standalone in Docker:
```
]$ git clone git@github.com:lipixx/docker-rh-ex.git
]$ cd docker-rh-ex/redis
]$ docker build  -t docker-rh-ex/redis .
]$ docker run --name redis docker-rh-ex/redis -d
```
By default redis will listen to all interfaces, so you can test a connection
from, for example, your local host:
```
]$ redis-cli -h 172.17.0.1
172.17.0.1:6379> get x
"12345"
172.17.0.1:6379> quit
```
##Step 2 - Ruby APP

For the ruby app, we use a single Dockerfile that installs a minimal CentOS
with ruby and the required gems: redis and sinatra.

We are going to connect the Ruby APP to Redis DB.

Sinatra must listen not only to localhost interfaces, (this is the default
behaviour), so we have added a line to the ruby app in order to intsruct it to
listen to all interfaces.

The added line is shown here:
```
--- original/hello-world.rb 2016-05-25 18:48:45.000000000 +0200
+++ new/hello-world.rb	2016-10-28 22:11:24.091627605 +0200
@@ -3,8 +3,6 @@ require 'redis'
  
 redis = Redis.new(:host => ENV["REDIS_HOST"] || "127.0.0.1" , :port =>  ENV["REDIS_PORT"] || 6379)
 
+set :bind, '0.0.0.0'
```

Moreover, the exercices demands us to use two custom variables, REDIS_HOST and
REDIS_PORT. When you link a container with another one, some default variables
are set in the environment. We must take this variables and map them to the
custom ones before runing the ruby application. This is achieved using a helper
script called run_hello-world.sh that is copied into the container and used
as the main entry point.

In OpenShift the variable passing is done the same way when you group applications.

There is another option: configure the variables statically when deploying
the container. If we want to do that we just need to set REDIS_HOST to the name of redis
app (redis), and REDIS_PORT to 6379. This could be acomplished when defining new app:

  ```oc new-app lipixx/app1 -e REDIS_HOST=redis -e POSTGRESQL_DATABASE=6379```

###Build & Run Ruby APP
```
]$ git clone github/docker-rh-ex/app1 .
]$ cd redis
]$ docker build -t docker-rh-ex/app1 .
```
Test it from localhost:
```
]$ docker run --link redis:redis -p 4567:4567 --name app1 docker-rh-ex/app1
]$ curl http://localhost:4567/
```
**Note:The second parameter of link, :redis, defines the prefix of the standard
variable naming. The entrypoint script is programmed to get "redis" as prefix.

##Step 3 - Uploading images to Docker Hub

We assume you have a Docker Hub account.

To see your images:
```
]$ docker images 
```

To push our images:
```
]$ docker push lipixx/redis
]$ docker push lipixx/app1
```

##Step 4 - Load Balancer (OpenShift approach)

For the load balancer we are going to use intrinsic features of Openshift. 

First of all we must sign-up for an account, or use Openshift Origin. Since I
had a preview account for RedHat OpenShift, I tried it directly there.

###Install oc tools

Access to the webconsole and click on "About". A link with instructions to
install oc tools is shown.

###Login and create a new project

Project Docker RedHat Exercise.

```
]$ oc login https://api.preview.openshift.com --token=*****
]$ oc new-project docker-rh-ex
]$ oc new-app lipixx/redis
]$ oc new-app lipixx/app1
```

At this point we created a project into our account called docker-rh-ex and
created the first two imagestreams and deployment of our app1 and redis apps.

If we wanted to use oficial redis image, we could just have omitted the lipixx/ 
in the second command.

###Networking within services and expose app1

From web console, group app1 and redis services.

Make access to app1 public:
```
]$ oc expose service/app1
```

Make the app1 Highly Available adding replicas to the replication controller:
```
]$ oc get rc
]$ oc scale --replicas=2 rc app1-1
```

##Accessing the app

Get the app1's URL entrypoint
```
]$ oc get routes
```

Port 4567 of app1 is exposed to internet through port 80, i.e.:

http://app1-docker-rh-ex.44fs.preview.openshiftapps.com/

shows:

```
"Hello World!" 
```

##Docker Compose

For testing purposes in your local environment you can use the provided compose
file to build app1 and redis images.

**Note: This is not tested yet.

##Manual Approach with a LBR

If we still wanted to use a LBR instead of OpenShift, the only thing that we
have to do is to create a Docker image with an Nginx or a HAProxy, configure it
with a template, expose ports 80 and 443 and link it with app1 application.

Then if wanted modify the docker-compose to add a network section with front-tier
and back-tier networks, and configure each service section accordingly.

See docker-compose.yml.lbr for an (untested) example.

##Extra commands

This is a cheatsheet for other common commands:

Connect to a pod (container):
```
]$ oc get pods
]$ oc rsh app1 bash
```
To stop:
```
]$ oc delete pod app1
```
Logs of a deployment:
```
]$ oc logs -f dc/app1
```

Update image manually:
```
]$ oc get imagestream
]$ oc import-image app1
]$ oc deploy app1 --latest -n docker-rh-ex (already done automatically when imported)
```
#Requirements: 

   - Full description of how to get the application running using the method you choose.
   
     Everything detailed here: https://github.com/lipixx/docker-rh-ex

   - A github repo with your dockerfiles, compose files, or all the info needed.

     https://github.com/lipixx/docker-rh-ex

   - You must provide a single endpoint to access the application, we will use `curl http(s)://ENDPOINT_PROVIDED` 

     The entry point is obtained with "oc get routes", for example: 
     ```
     http://app1-docker-rh-ex.44fs.preview.openshiftapps.com
     ```