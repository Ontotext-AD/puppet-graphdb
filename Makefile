DISTRO ?= ubuntu-server-1404-x64
GRAPHDB_VERSION ?= 7.1.0
GRAPHDB_TIMEOUT ?= 120
DEBUG ?= false

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
release: clean-logs clean
	rake module:bump:$(RELEASE_TYPE)
	BLACKSMITH_FORGE_USERNAME=$(BLACKSMITH_FORGE_USERNAME) \
	BLACKSMITH_FORGE_PASSWORD=$(BLACKSMITH_FORGE_PASSWORD) \
	rake module:release

.PHONY: test-acceptance
test-acceptance: .vendor
		GRAPHDB_VERSION=$(GRAPHDB_VERSION) \
		GRAPHDB_TIMEOUT=$(GRAPHDB_TIMEOUT) \
		BEAKER_set=$(DISTRO) \
		DEBUG=$(DEBUG) \
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
