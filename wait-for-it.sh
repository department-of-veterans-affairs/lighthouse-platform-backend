#!/bin/sh

set -e

cmd="$@"
attempts=0

# uses elasticsearch as it tends to take the longest
until [ "$(curl -s -o /dev/null -w '%{http_code}' 'elasticsearch:9200/_search')" -eq 200 ];
do
  echo "Waiting for Elasticsearch - sleeping"
  attempts=$((attempts+1))
  if [ "$attempts" -gt 9 ]; then
    echo "ES failed to respond - exiting"
    exit 1
  fi
  sleep 2
done

echo "ES is up - running tests"
exec $cmd
