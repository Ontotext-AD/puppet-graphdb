DISTRO ?= ubuntu-server-1404-x64
GRAPHDB_VERSION ?= 7.1.0
GRAPHDB_TIMEOUT ?= 120
PUPPET_VERSION ?= 3.7.5
DEBUG ?= false

.vendor: Gemfile
	bundle update || true
	bundle install --path .vendor
	touch .vendor

.PHONY: clean
clean:
	bundle exec rake spec_clean
	rm -rf .bundle .vendor junit

.PHONY: clean-logs
clean-logs:
	rm -rf log

.PHONY: release
release: clean-logs clean
	bundle exec rake module:clean
	bundle exec rake module:bump_commit:$(RELEASE_TYPE)
	git push
	bundle exec puppet module build
	bundle exec rake module:tag
	git push --tags
	BLACKSMITH_FORGE_USERNAME=$(BLACKSMITH_FORGE_USERNAME) \
	BLACKSMITH_FORGE_PASSWORD=$(BLACKSMITH_FORGE_PASSWORD) \
	bundle exec rake module:push

.PHONY: test-acceptance
test-acceptance: .vendor
		GRAPHDB_VERSION=$(GRAPHDB_VERSION) \
		GRAPHDB_TIMEOUT=$(GRAPHDB_TIMEOUT) \
		PUPPET_VERSION=$(PUPPET_VERSION) \
		BEAKER_set=$(DISTRO) \
		DEBUG=$(DEBUG) \
		bundle exec rspec spec/acceptance

.PHONY: test-rspec
test-rspec: .vendor
	bundle exec rake lint
	bundle exec rae validate
	bundle exec rake spec

.PHONY: guard
guard: .vendor
		bundle exec guard

.PHONY: coverage
coverage: .vendor
	COVERAGE=true bundle exec rake spec
