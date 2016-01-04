#!/bin/sh
while [ true ]
do
  ruby rb/update_prices.rb
  sleep 60
done
