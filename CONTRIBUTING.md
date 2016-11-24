# Contributing

If you have a bugfix or new feature that you would like to contribute to this puppet module, please find or open an issue about it first.
Talk about what you would like to do.

We enjoy working with contributors to get their code accepted.
There are many approaches to fixing a problem and it is important to find the best approach before writing too much code.

## Development Setup

There are a few testing prerequisites to meet:

* Ruby.
  As long as you have a recent version with `bundler` available, `bundler` will install development dependencies.

You can then install the necessary gems with:

    make

This will install the requisite rubygems for testing into `.vendor`.
Note that you can purge all testing fixtures/artifacts/gems with `make clean`.

* Docker.
  Note that Docker is used to run tests that require a Linux container/VM - if you only need to run simple rspec/doc tests, this shouldn't be necessary.
  If you are developing on a Linux machine with a working Docker instance, this should be sufficient.
  On OS X, just use the official [Docker installation method](https://docs.docker.com/engine/installation/mac/) to get a working `docker` setup.
  Confirm that you can communicate with the Docker hypervisor with `docker version`.

## Testing

Running through the tests on your own machine can get ahead of any problems others (or Jenkins) may run into.

First, run the rspec tests and ensure it completes without errors with your changes. These are lightweight tests.

    make test-rspec

Next, run the more thorough acceptance tests.
By default, the test will run against a GraphDB EE 7.1.0 deployed on Ubuntu 14.04 Docker image - other available hosts can be found in `spec/acceptance/nodesets`.
For example, to run the acceptance tests against CentOS 6, run the following:

    DISTRO=centos-6-x64 make test-acceptance

The final output line will tell you which, if any, tests failed.