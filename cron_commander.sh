#!/bin/sh
while [ true ]
do
  ruby rb/script/update_prices.rb
  sleep 60
done
