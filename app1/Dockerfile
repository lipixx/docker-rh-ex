FROM        centos:7.1.1503
RUN         yum install -y epel-release && yum clean all
RUN	    yum install -y ruby
RUN	    gem install redis sinatra
EXPOSE	    4567
RUN	    mkdir /app
WORKDIR	    /app/
COPY	    hello-world.rb /app/
COPY	    run_hello-world.sh /app/
RUN	    chmod 755 /app/run_hello-world.sh
ENTRYPOINT  ["/app/run_hello-world.sh"]
