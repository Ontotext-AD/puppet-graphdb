FROM ruby:2.7

WORKDIR /opt/puppet

# https://github.com/puppetlabs/puppet/blob/06ad255754a38f22fb3a22c7c4f1e2ce453d01cb/lib/puppet/provider/service/runit.rb#L39
RUN mkdir -p /etc/sv

ARG PUPPET_VERSION="~> 7.0"
ARG COVERAGE=true

# Cache gems
COPY Gemfile .
RUN bundle install --path=${BUNDLE_PATH:-vendor/bundle}

COPY . .

RUN bundle install

COPY Rakefile .
RUN bundle exec rake lint
RUN bundle exec rake validate
RUN bundle exec rake spec

# RUN bundle exec guard

# ARG	GRAPHDB_VERSION='9.10.2'
# ARG GRAPHDB_TIMEOUT=120
# ARG BEAKER_set='ubuntu-server-1604-x64'
# RUN	bundle exec rspec spec/acceptance

# Container should not saved
RUN exit 1