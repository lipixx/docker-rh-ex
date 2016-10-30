#!/bin/bash

export REDIS_HOST=$REDIS_PORT_6379_TCP_ADDR
export REDIS_PORT=$REDIS_PORT_6379_TCP_PORT

/usr/bin/ruby /app/hello-world.rb
