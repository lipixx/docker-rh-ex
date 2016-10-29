#!/bin/bash

export REDIS_HOST=$DB_PORT_6379_TCP_ADDR
export REDIS_PORT=$DB_PORT_6379_TCP_PORT

/usr/bin/ruby /app/hello-world.rb
