FROM        centos:7.1.1503
MAINTAINER  Felip Moll "lipixx@gmail.com"
EXPOSE	    4567
RUN         yum install -y epel-release && yum clean all
RUN	    yum install -y ruby
RUN	    gem install redis sinatra
RUN	    useradd -ms /bin/bash potato
RUN	    mkdir /app
WORKDIR	    /app/
COPY	    hello-world.rb /app/
COPY	    run_hello-world.sh /app/
RUN	    chown -R potato:potato /app/* && chmod 755 /app/run_hello-world.sh
USER	    potato
ENTRYPOINT  ["/app/run_hello-world.sh"]
