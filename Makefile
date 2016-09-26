DISTRO ?= ubuntu-server-1404-x64
GRAPHDB_VERSION ?= 7.1.0

.vendor: Gemfile
	bundle update || true
	bundle install --path .vendor
	touch .vendor

.PHONY: clean
clean:
	bundle exec rake spec_clean
	rm -rf .bundle .vendor

.PHONY: clean-logs
clean-logs:
	rm -rf log

.PHONY: release
release: clean-logs
	bundle exec puppet module build

.PHONY: test-acceptance
test-acceptance: .vendor
		GRAPHDB_VERSION=${GRAPHDB_VERSION} \
		BEAKER_set=$(DISTRO) \
		bundle exec rspec spec/acceptance

.PHONY: test-rspec
test-rspec: .vendor
	bundle exec rake lint
	bundle exec rake validate
	bundle exec rake spec

.PHONY: guard
guard: .vendor
		bundle exec guard

.PHONY: coverage
coverage: .vendor
	COVERAGE=true bundle exec rake spec
