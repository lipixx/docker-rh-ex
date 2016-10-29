FROM        centos:7.1.1503
RUN         yum install -y epel-release && yum clean all
RUN	    yum install -y redis
EXPOSE      6379
ENTRYPOINT  ["/usr/bin/redis-server"]
