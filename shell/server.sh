#!/bin/sh
touch server.pid
ruby rb/server.rb -e production -p 4567
