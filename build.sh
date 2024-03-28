#!/usr/bin/env bash
set -euo pipefail
ECR_REGISTRY=533575416491.dkr.ecr.us-gov-west-1.amazonaws.com
BASEDIR=$(readlink -f $(dirname $0))
RELEASE=${RELEASE:-false}
REPOSITORY=${ECR_REGISTRY}/lighthouse-platform-backend
VERSION=${VERSION:-$(cat $BASEDIR/VERSION)}

aws ecr get-login-password --region us-gov-west-1 | docker login --username AWS --password-stdin $ECR_REGISTRY
trap "docker-compose -f docker-compose.yml -f docker-compose.dependencies.yml down -v --rmi local" EXIT

echo 'Building container and running CI'
docker-compose -f docker-compose.yml -f docker-compose.dependencies.yml build --no-cache
docker-compose -f docker-compose.yml -f docker-compose.dependencies.yml run app /bin/bash wait-for-it.sh bundle exec rails db:create ci

echo 'Building production container...'
docker build --pull --file $BASEDIR/Dockerfile --target prod --tag $REPOSITORY:$VERSION $BASEDIR

if [ $RELEASE == true ]; then
  echo 'Logging in to ECR...'
  echo 'Pushing '$REPOSITORY:$VERSION
  docker push $REPOSITORY:$VERSION
  docker tag $REPOSITORY:$VERSION $REPOSITORY:latest
  docker push $REPOSITORY:latest
fi
