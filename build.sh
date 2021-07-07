#!/usr/bin/env bash
set -euo pipefail
ECR_REGISTRY=533575416491.dkr.ecr.us-gov-west-1.amazonaws.com
BASEDIR=$(readlink -f $(dirname $0))
RELEASE=${RELEASE:-false}
REPOSITORY=${ECR_REGISTRY}/lighthouse-platform-backend
VERSION=${VERSION:-$(cat $BASEDIR/VERSION)}

docker build --pull -f $BASEDIR/Dockerfile -t $REPOSITORY-base:$VERSION $BASEDIR

# lint, security, specs with coverage tasks run on the ci task
docker run --rm $REPOSITORY-base:$VERSION bundle exec rails ci

# keeping this as reference for when we have integration tests
# # integration tests are currently handled in the rails ci job
# if docker run --network="host" $REPOSITORY-base:$VERSION npm run test:integration
# then
#   docker stop test-database
# else
#   docker stop test-database
#   exit 1
# fi

if [ $RELEASE == true ]; then
  aws ecr get-login-password --region us-gov-west-1 | docker login --username AWS --password-stdin $ECR_REGISTRY
  docker push $REPOSITORY:$VERSION
  docker tag $REPOSITORY:$VERSION $REPOSITORY:latest
  docker push $REPOSITORY:latest
fi
