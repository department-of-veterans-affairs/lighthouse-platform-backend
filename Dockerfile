# Ideally this is pulled from a private container registry for security purposes
FROM ruby:3.0.0-slim-buster AS base
WORKDIR /home/ruby

# Install packages needed for ruby gems and to run rails
RUN apt-get update -qq && apt-get install -y \
  curl 

RUN curl -k https://gist.githubusercontent.com/duganth-va/2f421f56e246de0546b3966d0b0a1c66/raw/2cd8b42d6adfd9b83a2db449aa11c7296db37faf/va-debian.sh | /bin/bash

RUN curl -sL https://deb.nodesource.com/setup_14.x | bash -\
  && apt-get update -qq && apt-get install -qq --no-install-recommends \
    nodejs

RUN apt-get update -qq && apt-get install -y \
  build-essential \
  libpq-dev \
  shared-mime-info \
  postgresql-client && \
  curl -fsSl https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
  echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
  apt-get update && apt-get install -y yarn git

COPY Gemfile Gemfile.lock ./
RUN gem update bundler

FROM base AS ci

# Install ruby dependencies
RUN bundle install --jobs 5 --binstubs="./bin"
# Install javascript dependencies
COPY package.json yarn.lock ./
RUN yarn install

ARG rails_env=test
ENV RAILS_ENV=$rails_env

# Copy source code for application
COPY . .

# Precompile assets
RUN bundle exec rails assets:precompile
RUN ./bin/webpack

# Production Stage
FROM base AS prod

ARG rails_env=production
ENV RAILS_ENV=$rails_env
ENV NODE_ENV=$rails_env
ENV RAILS_SERVE_STATIC_FILES=true
ENV SECRET_KEY_BASE=DEFAULT_VALUE_OVERRIDE_AT_RUNTIME
ENV RAILS_ENV=production
# COPY --from=builder $BUNDLE_APP_CONFIG $BUNDLE_APP_CONFIG
# Install ruby dependencies

RUN bundle install --jobs 5 --without development test

# Copy source code for application
COPY . .

# Precompile assets
RUN bundle exec rails assets:precompile
RUN ./bin/webpack

# Add a script to be executed every time the container starts.
COPY bin/entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 8080
# Start the main process.
CMD ["rails", "server", "-b", "0.0.0.0", "-p", "8080"]
