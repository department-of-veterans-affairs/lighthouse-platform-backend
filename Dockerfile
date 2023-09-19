FROM ghcr.io/department-of-veterans-affairs/health-apis-docker-octopus/lighthouse-ruby-application-base:v2-ruby3 AS base

ENV BUNDLER_VERSION=2.2.23

WORKDIR /home/ruby

COPY Gemfile Gemfile.lock ./
RUN gem install bundler:${BUNDLER_VERSION}

# ----

FROM base AS ci

RUN bundle install --jobs 5 --binstubs="./bin"
COPY . .
RUN bundle exec rails assets:precompile

# ----

FROM base AS prod

RUN bundle install --jobs 5 --without development test
COPY . .
RUN RAILS_ENV=production SECRET_KEY_BASE=DEFAULT_VALUE_OVERRIDE_AT_RUNTIME bundle exec rails assets:precompile

COPY bin/entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 8080

CMD ["rails", "server", "-b", "0.0.0.0", "-p", "8080"]
