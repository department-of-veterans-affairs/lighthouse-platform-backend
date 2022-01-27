FROM vasdvp/health-apis-centos:8 AS base

ENV RUBY_MAJOR_VERSION=3.0
ENV RUBY_VERSION=3.0.0
ENV BUNDLER_VERSION=2.2.23

RUN yum install -y -q git \
  openssl-devel \
  gcc \
  gcc-c++ \
  make \
  postgresql-libs \
  postgresql-devel \
  shared-mime-info

RUN curl -sL "https://cache.ruby-lang.org/pub/ruby/${RUBY_MAJOR_VERSION}/ruby-${RUBY_VERSION}.tar.xz" -o ruby.tar.xz && \
  tar -xJf ruby.tar.xz -C /tmp/ && \
  rm ruby.tar.xz && \
  cd /tmp/ruby-${RUBY_VERSION} && \
  ./configure --silent \
    --disable-install-doc && \
  make && \
  make install && \
  rm -r /tmp/ruby-${RUBY_VERSION}

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
