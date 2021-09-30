FROM vasdvp/health-apis-centos:8 AS base

ENV RUBY_MAJOR_VERSION 3.0
ENV RUBY_VERSION 3.0.0
ENV BUNDLER_VERSION 2.2.23
ENV NODE_VERSION 14

RUN yum groupinstall -y -q "Development Tools"
RUN yum install -y -q git \
  openssl-devel \
  gcc \
  gcc-c++ \
  make \
  postgresql-libs \
  postgresql-devel \
  shared-mime-info

RUN curl -sL https://cache.ruby-lang.org/pub/ruby/${RUBY_MAJOR_VERSION}/ruby-${RUBY_VERSION}.tar.gz | tar -zxvf - -C /tmp/ && \
  cd /tmp/ruby-${RUBY_VERSION} && \
  ./configure && \
  make && \
  make install

RUN curl -sL https://rpm.nodesource.com/setup_${NODE_VERSION}.x | bash -
RUN curl -sL https://dl.yarnpkg.com/rpm/yarn.repo | tee /etc/yum.repos.d/yarn.repo && \
  rpm --import https://dl.yarnpkg.com/rpm/pubkey.gpg

RUN yum install -y -q nodejs yarn

WORKDIR /home/ruby

COPY Gemfile Gemfile.lock ./
RUN gem install bundler:${BUNDLER_VERSION}

FROM base AS ci

# Install ruby dependencies
RUN bundle install --jobs 5 --binstubs="./bin"
# Install javascript dependencies
COPY . .

RUN openssl x509 \
  -inform der \
  -in /etc/pki/ca-trust/source/anchors/VA-Internal-S2-RCA1-v1.cer \
  -out /home/ruby/va-internal.pem
ENV NODE_EXTRA_CA_CERTS=/home/ruby/va-internal.pem

ARG rails_env=test
ENV RAILS_ENV=$rails_env

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
