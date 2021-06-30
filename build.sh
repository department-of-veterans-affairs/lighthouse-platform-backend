#!/usr/bin/env bash
set -euo pipefail
ECR_REGISTRY=533575416491.dkr.ecr.us-gov-west-1.amazonaws.com
BASEDIR=$(readlink -f $(dirname $0))
RELEASE=${RELEASE:-false}
REPOSITORY=${ECR_REGISTRY}/lighthouse-platform-backend
VERSION=${VERSION:-$(cat $BASEDIR/VERSION)}
POSTGRES_USER=lighthouse
POSTGRES_PASSWORD=L1ghth0us3
POSTGRES_DB=lighthouse_platform_backend_test




# docker network create lpb-cicd-net
# 
# docker build --pull --target base -f $BASEDIR/Dockerfile -t $REPOSITORY-base:$VERSION $BASEDIR
# 
# docker run -d --rm --name lpb-test-database --network lpb-cicd-net -e POSTGRES_DB=$POSTGRES_DB -e POSTGRES_USER=$POSTGRES_USER -e POSTGRES_PASSWORD=$POSTGRES_PASSWORD -p 127.0.0.1:5679:5432 postgres:12.4-alpine
# 
# #docker run -d --rm --name lpb-test-database -e POSTGRES_DB=$POSTGRES_DB -e POSTGRES_USER=$POSTGRES_USER -e POSTGRES_PASSWORD=$POSTGRES_PASSWORD -p 127.0.0.1:5679:5432 postgres:12.4-alpine
# 
# # create test db
# # extremely similar to ci command below
# docker run --name $REPOSITORY-base:$VERSION -e RAILS_ENV=test --rm --network=lpb-cicd-net -p 127.0.0.1:3000:3000 $REPOSITORY-base:$VERSION sh -c "rails db:create"
# 
# # lint
# # security
# # specs with coverage
# docker run --rm --network lpb-cicd-net $REPOSITORY-base:$VERSION bundle exec rails ci
# 
# docker run --name $REPOSITORY-base:$VERSION -e RAILS_ENV=test --rm --network=lpb-cicd-net -p 127.0.0.1:3000:3000 $REPOSITORY-base:$VERSION sh -c "rails db:create"

docker-compose run app bundle exec rails db:create  ci

# docker stop lpb-test-database
# # integration tests are currently handled in the rails ci job
# if docker run --network="host" $REPOSITORY-base:$VERSION npm run test:integration
# then
#   docker stop test-database
# else
#   docker stop test-database
#   exit 1
# fi


# docker network rm lpb-cicd-net

docker-compose down

# docker build --pull -f $BASEDIR/Dockerfile -t $REPOSITORY:$VERSION $BASEDIR


if [ $RELEASE == true ]; then
  aws ecr get-login-password --region us-gov-west-1 | docker login --username AWS --password-stdin $ECR_REGISTRY
  docker push $REPOSITORY:$VERSION
  docker tag $REPOSITORY:$VERSION $REPOSITORY:latest
  docker push $REPOSITORY:latest
fi
