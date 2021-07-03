# Ideally this is pulled from a private container registry for security purposes
FROM ruby:3.0.0-slim-buster AS base
WORKDIR /home/ruby

# Install packages needed for ruby gems and to run rails
RUN apt-get update -qq && apt-get install -y \
  curl 

RUN curl -k https://gist.githubusercontent.com/duganth-va/2f421f56e246de0546b3966d0b0a1c66/raw/2cd8b42d6adfd9b83a2db449aa11c7296db37faf/va-debian.sh | /bin/bash

RUN apt-get update -qq && apt-get install -y \
  build-essential \
  libpq-dev \
  shared-mime-info \
  postgresql-client \
  git \
  nodejs \
  yarn && \
  curl -fsSl https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
  echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
  apt-get update && apt-get install -y nodejs yarn git

# Install ruby dependencies
COPY Gemfile Gemfile.lock ./
RUN gem update bundler
RUN bundle install --jobs 5 --binstubs="./bin"
# Install javascript dependencies
COPY package.json yarn.lock ./
RUN yarn install

ARG rails_env=test
ENV RAILS_ENV=$rails_env
# Copy source code for application
COPY . .


# Production Stage
FROM ruby:3.0.0-slim-buster AS prod

ARG rails_env=production
ENV RAILS_ENV=$rails_env
ENV RAILS_SERVE_STATIC_FILES=true
ENV SECRET_KEY_BASE=CHANGE_ME_LATER

# Precompile assets
RUN bin/rails rails assets:precompile
RUN bin/rails rails webpacker:compile

# Copy source code for application
COPY . .

# Add a script to be executed every time the container starts.
COPY bin/entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000
# Start the main process.
CMD ["rails", "server", "-b", "0.0.0.0"]
