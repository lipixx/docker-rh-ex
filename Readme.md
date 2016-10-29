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
#Implementation of the separate components
##Step 1 - REDIS Database

In order to provide a dockerized redis server, we could us the official image 
of REDIS available on DockerHub.

The other alternative is to simply import a minimal image, like the centos one,
and to install and configure the database within that image.

This last approach is used in this exercice. Configuration of the server has
been set by default.

###Build&Run REDIS Database container

To build and test it standalone in Docker:
```
]$ git clone git@github.com:lipixx/docker-rh-ex.git
]$ cd docker-rh-ex/redis
]$ docker build  -t docker-rh-ex/redis .
]$ docker run --name redis docker-rh-ex/redis -d
```
By default redis will listen to all interfaces, so you can test a connection
from for example your local host:
```
]$ redis-cli -h 172.17.0.1
172.17.0.1:6379> get x
"12345"
172.17.0.1:6379> quit
```
##Step 2 - Ruby APP

For the ruby app, we use a single Dockerfile that installs a minimal CentOS
with ruby and the required gems, redis and sinatra.

We are going to connect the Ruby APP to a LBR, and also to Redis DB.

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
script called run_hello-world.sh, that is copied into the container and used
as the main entry point.

**Note about the app: There is a redis.ping command that outputs nothing. If you want to see
anything you should add "redis.ping" as an argument to puts: "puts redis.ping"**

###Build & Run Ruby APP
```
]$ git clone github/docker-rh-ex/app1 .
]$ cd redis
]$ docker build -t docker-rh-ex/app1 .
```
Test it from localhost:
```
]$ docker run --link redis:db -p 4567:4567 --name app1 docker-rh-ex/app1
]$ curl http://localhost:4567/
```
##Load Balancer

For the load balancer we wanted to use Openshift. We will import our two
dockerfiles into openshift, and setup a network that will provide access and
LBR to our app.

# Adding the components to OpenShift and providing the final endpoint

oc login https://api.preview.openshift.com
oc project redhat-i1
oc status
oc delete dc app -n redhat-i1
oc start-build app1 -n redhat-i1


#Requirements: 

   - Full description of how to get the application running using the method you choose.
   - A github repo with your dockerfiles, compose files, or all the info needed.
   - You must provide a single endpoint to access the application, we will use `curl http(s)://ENDPOINT_PROVIDED` 

