#!/bin/bash

cmd="$@"

sleep 10

substrate_status=$(curl --write-out '%{http_code}' --silent --output /dev/null http://doton-sub-chain:9615/metrics)

until [ $substrate_status = 200 ]; do
  >&2 echo "Substrate status:" $ton_status
  >&2 echo "Substrate is unavailable - sleeping"
  sleep 1
done

>&2 echo "Substrate status:" $substrate_status

ton_status=$(curl --write-out '%{http_code}' --silent --output /dev/null http://doton-ton-chain/graphql?query=%7Binfo%7Bversion%7D%7D)

until [ $ton_status = 200 ]; do
  >&2 echo "TON status:" $ton_status
  >&2 echo "TON is unavailable - sleeping"
  sleep 1
done

>&2 echo "TON status:" $ton_status

exec $cmd