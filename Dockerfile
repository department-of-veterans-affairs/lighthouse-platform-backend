# Ideally this is pulled from a private container registry for security purposes
FROM ruby:3.0.0-slim-buster AS base
WORKDIR /app

# Install packages needed for ruby gems and to run rails
RUN apt-get update -qq && apt-get install -y \
  curl \
  build-essential \
  libpq-dev \
  shared-mime-info \
  postgresql-client && \
  curl -fsSl https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
  echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list # && \
# apt-get update && apt-get install -y nodejs yarn git

RUN curl  https://gist.githubusercontent.com/duganth-va/2f421f56e246de0546b3966d0b0a1c66/raw/2cd8b42d6adfd9b83a2db449aa11c7296db37faf/va-debian.sh | /bin/bash

# Install ruby dependencies
# TODO: Bundle into vendor/cache and map as volume: https://stackoverflow.com/a/61208108/705131
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
RUN gem update bundler
RUN bundle install --jobs 5
# Install javascript dependencies
COPY package.json /app/package.json
COPY yarn.lock /app/yarn.lock
RUN yarn install
# Copy source code for application
COPY . /app

RUN /bin/bash -c "curl -L https://github.com/fgrehm/notify-send-http/releases/download/v0.2.0/client-linux_amd64 | tee /usr/local/bin/notify-send &>/dev/null"
RUN chmod +x /usr/local/bin/notify-send
ARG rails_env=development
ENV RAILS_ENV=$rails_env
ENV NOTIFY_SEND_URL="http://172.17.0.1:12345"
# Add a script to be executed every time the container starts.
COPY bin/entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000
# Start the main process.
CMD ["rails", "server", "-b", "0.0.0.0"]
