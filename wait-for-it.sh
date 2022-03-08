#!/bin/sh

set -e

cmd="$@"
attempts=0

until [ "$(curl -s -o /dev/null -w '%{http_code}' 'elasticsearch:9200/_search')" -eq 200 ];
do
  echo "Waiting for Containers - sleeping"
  attempts=$((attempts+1))
  if [ "$attempts" -gt 14 ]; then
    echo "ES failed to respond - exiting"
    exit 1
  fi
  sleep 1
done

echo "ES is up - running tests"
exec $cmd