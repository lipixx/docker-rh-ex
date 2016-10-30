FROM        centos:7.1.1503
MAINTAINER  Felip Moll "lipixx@gmail.com"
EXPOSE      6379
RUN         yum install -y epel-release && yum clean all
RUN	    yum install -y redis
RUN	    useradd -ms /bin/bash potato
USER	    potato
ENTRYPOINT  ["/usr/bin/redis-server"]
