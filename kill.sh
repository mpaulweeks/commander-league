#!/bin/sh
sudo kill `cat server.pid`
cat /dev/null > server.pid
