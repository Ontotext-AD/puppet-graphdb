GraphDB Puppet module
---------------------

[![Build Status](https://jenkins.ontotext.com/buildStatus/icon?job=puppet-graphdb)](https://jenkins.ontotext.com/job/puppet-graphdb)
[![Puppet Forge endorsed](https://img.shields.io/puppetforge/e/ontotext/graphdb.svg)](https://forge.puppetlabs.com/ontotext/graphdb)
[![Puppet Forge Version](https://img.shields.io/puppetforge/v/ontotext/graphdb.svg)](https://forge.puppetlabs.com/ontotext/graphdb)
[![Puppet Forge Downloads](https://img.shields.io/puppetforge/dt/ontotext/graphdb.svg)](https://forge.puppetlabs.com/ontotext/graphdb)

#### Table of Contents

1. [Module description - What the module does and why it is useful](#module-description)
2. [Setup - The basics of getting started with GraphDB](#setup)
  * [The module manages the following](#the-module-manages-the-following)
  * [Requirements](#requirements)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Advanced features - Extra information on advanced usage](#advanced-features)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)
7. [Support - When you need help with this module](#support)
8. [License](#license)

## Module description

This module sets up [GraphDB](http://graphdb.ontotext.com/) instances with additional resource for
repository creation, data loading, updates, backups, and more.

This module has been tested against all major versions of GraphDB 7.* and 8.*

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

#### Automatically restarting the service (default set to true)

By default, the module will restart GraphDB when the configuration file changed.
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
  logback_config     => undef, # custom GraphDB logback log configuration
  extra_properties   => { }, # extra properties for graphdb.properties file
  heap_size          => '2g', # GraphDB  java heap size given by -Xmx parameter. Note heap_size parameter will also set xms=xmx
  java_opts          => [], # extra java opts for java process
}
```

### Cluster

Optimum GraphDB EE cluster configuration 

1. Master worker linking parameters:
* master_repository_id (**required**)
* master_endpoint (**required**)
* worker_repository_id (**required**)
* worker_endpoint (**required**)
* replication_port (**optional**; default to 0)
2. Master master linking parameters:
* master_repository_id (**required**)
* master_endpoint (**required**)
* peer_master_endpoint (**required**)
* peer_master_repository_id (**required**)
* peer_master_node_id (**optional** if you define graphdb_link on the same node as registered GraphDB master instance)


#### Quick setup

A master with one worker

```
 class { 'graphdb':
   version => '7.1.0',
   edition => 'ee',
 }
 
 graphdb::instance { 'master':
   license        => '/tmp/ee.license',
   jolokia_secret => 'duper',
   http_port      => 8080,
 }
 
 graphdb::ee::master::repository { 'master':
   endpoint           => "http://${::ipaddress}:8080",
   repository_context => 'http://ontotext.com/pub/',
 }
 
 graphdb::instance { 'worker':
   license   => '/tmp/ee.license',
   http_port => 8082,
 }
 
 graphdb::ee::worker::repository { 'worker':
   endpoint           => "http://${::ipaddress}:8082",
   repository_context => 'http://ontotext.com/pub/',
 }
 
 graphdb_link { 'master-worker':
   master_repository_id => 'master',
   master_endpoint      => "http://${::ipaddress}:8080",
   worker_repository_id => 'worker',
   worker_endpoint      => "http://${::ipaddress}:8082",
 }
```

A two peered masters([split brain](http://graphdb.ontotext.com/documentation/enterprise/ee/cluster-failures.html?highlight=master%20master#split-brain))

```
node 'master1' {

  class { 'graphdb':
    version => '#{graphdb_version}',
    edition => 'ee',
  }

  graphdb::instance { 'master1':
    license        => '/tmp/ee.license',
    jolokia_secret => 'duper',
    http_port      => 8080,
  }

  graphdb::ee::master::repository { 'master1':
    repository_id      => 'master1',
    endpoint           => "http://${::ipaddress}:8080",
    repository_context => 'http://ontotext.com/pub/',
  }

  graphdb_link { 'master1-to-master2':
    master_repository_id      => 'master2',
    master_endpoint           => "http://${::ipaddress}:9090",
    peer_master_repository_id => 'master1',
    peer_master_endpoint      => "http://${::ipaddress}:8080",
  }
}

node 'master2' {
  graphdb::instance { 'master2':
    license        => '/tmp/ee.license',
    jolokia_secret => 'duper',
    http_port      => 9090,
  }

  graphdb::ee::master::repository { 'master2':
    repository_id      => 'master2',
    endpoint           => "http://${::ipaddress}:9090",
    repository_context => 'http://ontotext.com/pub/',
  }

  graphdb_link { 'master2-to-master1':
    master_repository_id      => 'master1',
    master_endpoint           => "http://${::ipaddress}:8080",
    peer_master_repository_id => 'master2',
    peer_master_endpoint      => "http://${::ipaddress}:9090",
  }
}
```

#### Link Advanced options

##### GraphDB Master repository options can be given

```
 graphdb::ee::master::repository { 'master':
...
  $repository_template = "${module_name}/repository/master.ttl.erb", # ttl template to use as source for repository creation template
  $repository_label = 'GraphDB EE master repository', # repository label
  $node_id          = $title, # node id of master instance
  $timeout = 60, # timeout for repository creation operations
...
 }
```

##### GraphDB Worker repository options can be given

* For `EE`, please, check [here](manifests/ee/worker/repository.pp). Also, please, check [GraphDB EE documentation](http://graphdb.ontotext.com/documentation/enterprise/configuring-a-repository.html).
* For `SE`, please, check [here](manifests/se/worker/repository.pp). Also, please, check [GraphDB SE documentation](http://graphdb.ontotext.com/documentation/standard/configuring-a-repository.html).

##### Link specific options can be given

```
 graphdb_link { 'master-worker':
    ...
    replication_port     => 0 # The port for replications that master and worker will use; default: 0
    ...
}
```

##### Setup backup cron job
```
graphdb::ee::backup_cron { 'backup-cronjob':
    master_endpoint   => "http://${::ipaddress}:8080",
    master_repository => 'master',
    jolokia_secret    => 'duper',
    hour              => '4',
    minute            => '20',
}
```

## Advanced features

#### Perform SPARQL update

Example performs update(`update_query`) on the give repository(`repository_id`), but only if the ask query(`exists_query`) doesn't return true(`exists_expected_response`).

```
 graphdb_update { 'update':
    repository_id            => 'repository',
    endpoint                 => "http://${::ipaddress}:8080",
    update_query             => 'PREFIX geo-ont: <http://www.test.org/ontology#>
                                 INSERT DATA { <http://test> geo-ont:test "This is a test title" }',
    exists_query             =>  'ask { <http://test> ?p ?o . }',
    exists_expected_response => true,
}
```

#### Data import

##### GraphDB data define

Example triggers import of archive with data(`archive`), but only if ask query(`exists_query`) doesn't return true.
You can include multiple files into archive in various formats, but keep file extension relative to data format.
Also keep in mind that data import operation takes time, adjust timeout according to data size.

```
graphdb::data{ 'data-zip':
    repository          => 'test-repo',
    endpoint            => "http://${::ipaddress}:8080",
    archive             => 'puppet:///modules/test/test.ttl.zip',
    exists_query        =>  'ask { <http://test> ?p ?o . } ',
}
```

##### GraphDB data custom type
Example import data(`data`) with format(`data_format`) into repository(`repository_id`), but only if ask query(`exists_query`) doesn't return false.
You can also provide data source(`data_source`) which can be a file or directory.
If you keep the file extension relative to data format you data providing data format(`data_format`) is not required.
Also keep in mind that data import operation takes time, adjust timeout according to data size.

```
graphdb_data { 'test-data':
    repository_id       => 'test-repo',
    endpoint            => "http://${::ipaddress}:8080",
    data                => '
        @base <http://test.com#>.
        @prefix test:   <http://test.com/ontologies/test#> .
        <http://test>
                a                test:good ;
                test:price       "5" .
    ',
    exists_query        =>  'ask { <http://test> ?p ?o . } ',
    data_format         => 'turtle',
}
```

For more information about syntax, please, check [here](lib/puppet/type/graphdb_data.rb).

## Limitations

This module has been built on and tested against Puppet 3.2 and higher.

The module has been tested on:

* Debian 7/8
* CentOS 6/7
* Ubuntu 12.04, 14.04

Because of init.d/systemd/upstart support the module may run on other platforms, but it's not guaranteed.
   
## Development

Please see the [CONTRIBUTING.md](https://github.com/Ontotext-AD/puppet-graphdb/CONTRIBUTING.md) file for instructions regarding development environments and testing.

## Support

Please, use [email](mailto:graphdb-support@ontotext.com?Subject=GraphDB%20puppet%20module) or open an [issue](https://github.com/Ontotext-AD/puppet-graphdb/issues).

## License

Please see the [LICENSE](https://github.com/Ontotext-AD/puppet-graphdb/LICENSE) 
