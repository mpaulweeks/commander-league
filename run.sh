#!/bin/sh
nohup rvmsudo ruby rb/server.rb -e production -p 80 &
