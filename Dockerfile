FROM ruby:3.0.0-slim-buster AS base
WORKDIR /home/ruby

RUN apt-get update -qq && apt-get install -y \
  curl

RUN apt-get update -qq && apt-get install -y \
  build-essential \
  libpq-dev \
  shared-mime-info \
  postgresql-client && \
  apt-get update && apt-get install -y git

COPY Gemfile Gemfile.lock ./
RUN gem update bundler




FROM base AS ci

RUN bundle install --jobs 5
COPY . .
RUN bundle exec rails assets:precompile




FROM base AS prod

RUN bundle install --jobs 5 --without development test
COPY . .
RUN bundle exec rails assets:precompile

COPY bin/entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 8080

CMD ["rails", "server", "-b", "0.0.0.0", "-p", "8080"]
