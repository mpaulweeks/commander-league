#!/bin/sh
touch server.pid
rvmsudo ruby rb/server.rb -e production -p 80
