#!/usr/bin/env bash
set -euo pipefail
ECR_REGISTRY=533575416491.dkr.ecr.us-gov-west-1.amazonaws.com
BASEDIR=$(readlink -f $(dirname $0))
RELEASE=${RELEASE:-false}
REPOSITORY=${ECR_REGISTRY}/lighthouse-platform-backend
VERSION=${VERSION:-$(cat $BASEDIR/VERSION)}

trap "docker-compose down -v" EXIT

echo 'Building container and running CI'
docker-compose run app bundle exec rails db:create ci

echo 'Building production container...'
docker build --pull -f $BASEDIR/Dockerfile -t $REPOSITORY:$VERSION $BASEDIR

if [ $RELEASE == true ]; then
  echo 'Logging in to ECR...'
  aws ecr get-login-password --region us-gov-west-1 | docker login --username AWS --password-stdin $ECR_REGISTRY
  echo 'Pushing '$REPOSITORY:$VERSION
  docker push $REPOSITORY:$VERSION
  docker tag $REPOSITORY:$VERSION $REPOSITORY:latest
  docker push $REPOSITORY:latest
fi
