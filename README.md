GraphDB Puppet module
---------------------

[![Build Status](http://jenkins.ontotext.com/job/puppet-graphdb/badge/icon)](http://jenkins.ontotext.com/job/puppet-graphdb)


#### Table of Contents

1. [Module description - What the module does and why it is useful](#module-description)
2. [Setup - The basics of getting started with GraphDB](#setup)
  * [The module manages the following](#the-module-manages-the-following)
  * [Requirements](#requirements)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Advanced features - Extra information on advanced usage](#advanced-features)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
6. [Limitations - OS compatibility, etc.](#limitations)
7. [Development - Guide for contributing to the module](#development)
8. [Support - When you need help with this module](#support)

## Module description

This module sets up [GraphDB](http://graphdb.ontotext.com/) instances with additional resource for
repository creation, data loading, updates, backups, and more.

This module has been tested against all versions of GraphDB 7.*

## Setup

### The module manages the following

* GraphDB repository files.
* GraphDB distribution.
* GraphDB configuration file.
* GraphDB service.
* GraphDB plugins.

### Requirements

* The [stdlib](https://forge.puppetlabs.com/puppetlabs/stdlib) Puppet library.


### Beginning with GraphDB

Declare the top-level `graphdb` class and set up an instance:

```puppet
class{ 'graphdb':
  version              => '7.1.0',
  edition              => 'SE',
}

graphdb::instance { 'graphdb-instance':
   license           => '/home/graphdb/graphdb.license',
}
```

## Usage

Most top-level parameters in the `graphdb` class are set to reasonable defaults.
The following are some parameters that may be useful to override:

#### Removal/Decommissioning

```puppet
class { 'graphdb':
  ensure => 'absent'
}
```

#### Install everything but disable service(s) afterwards

```puppet
class { 'graphdb':
  version              => '7.1.0',
  edition              => 'SE',
  status               => 'disabled'
}
```

#### Automatically restarting the service (default set to false)

By default, the module will not restart GraphDB when the configuration file changed.
This can be overridden globally with the following option:

```puppet
class { 'graphdb':
  version              => '7.1.0',
  edition              => 'SE',
  restart_on_change    => false,
}
```

### Instances

This module works with the concept of instances. For service to start you need to specify at least one instance.

#### Quick setup

```puppet
graphdb::instance { 'graphdb-instance': license => '/home/graphdb/graphdb.license' }
```

This will set up its own data directory and set the service name to: graphdb-instance

#### Advanced options

Instance specific options can be given:

```puppet
graphdb::instance { 'graphdb-instance':
  http_port          => 8080, # http port that GraphDB will use
  kill_timeout       => 180, # time before force kill of GraphDB process
  validator_timeout  => 60, # GraphDB repository validator timeout
  jolokia_secret     => undef, # julokia secret for http jmx requests
  extra_properties   => { }, # extra properties for graphdb.properties file
  java_opts          => [], # extra java opts for java process
}
```
