#!/usr/bin/env bash
set -euo pipefail
ECR_REGISTRY=533575416491.dkr.ecr.us-gov-west-1.amazonaws.com
BASEDIR=$(readlink -f $(dirname $0))
RELEASE=${RELEASE:-false}
REPOSITORY=${ECR_REGISTRY}/lighthouse-platform-backend
VERSION=${VERSION:-$(cat $BASEDIR/VERSION)}
POSTGRES_USER=lighthouse_platform_backend_user
POSTGRES_PASSWORD=okapi
POSTGRES_DB=lighthouse_platform_backend_test

# builds RAILS_ENV=test for CI
echo 'Building base image...'
docker build --pull --target ci -f $BASEDIR/Dockerfile -t $REPOSITORY-base:$VERSION $BASEDIR

# creates network to connect DB and CI
echo 'Creating network'
TEST_NETWORK=n$(cat /proc/sys/kernel/random/uuid | tr '-' 'd')
docker network create -d bridge $TEST_NETWORK

# starts and runs PG container
echo 'Running db container...'
DB_CONTAINER=c$(cat /proc/sys/kernel/random/uuid | tr '-' 'd')
docker run -d --rm --name $DB_CONTAINER --network=$TEST_NETWORK -e POSTGRES_DB=$POSTGRES_DB -e POSTGRES_USER=$POSTGRES_USER -e POSTGRES_PASSWORD=$POSTGRES_PASSWORD -p 5432 postgres:13.1

# lint, security, specs with coverage tasks run on the ci task
if docker run --rm --network=$TEST_NETWORK -e DB_HOST=$DB_CONTAINER -e POSTGRES_USER=$POSTGRES_USER -e POSTGRES_PASSWORD=$POSTGRES_PASSWORD $REPOSITORY-base:$VERSION bundle exec rails ci
then
  echo 'CI ran successfully...'
  docker stop $DB_CONTAINER
  docker network rm $TEST_NETWORK
else
  echo 'CI failed miserably...'
  docker logs $DB_CONTAINER
  docker stop $DB_CONTAINER
  docker network rm $TEST_NETWORK
  exit 1
fi

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
