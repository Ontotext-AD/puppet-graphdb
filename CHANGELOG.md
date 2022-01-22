# Changelog

All notable changes to this project will be documented in this file.
Each new release typically also includes the latest modulesync defaults.
These should not affect the functionality of the module.

## [v0.6.0](https://github.com/phaedriel/puppet-graphdb/releases/tag/v0.6.0) (22 Jan 2022)

__UPGRADE__
- Ruby minimum 2.0.0

__CHANGE__
- Remove graphdb::ee::backup_cron (and his spec)
- Modify command unpack-graphdb-plugin (rm path and add chown)
- Remove useless condition in params.pp 
- Remove oldest versions in metadata.json
- Add debian 10 version in metadata.json
- Many rubocop corrections : frozen_string_literal ... etc
- Remove some file in spec/acceptance/nodesets (add debian 10)
- Modify errors on master_master_link_manager_spec.rb and master_worker_link_manager_spec.rb

## [v0.5.2](https://github.com/Ontotext-AD/puppet-graphdb/releases/tag/0.5.2) (30 Nov 2020)

- [Releases](https://github.com/Ontotext-AD/puppet-graphdb/releases)
- [Full Changelog](https://github.com/Ontotext-AD/puppet-graphdb/commits/master)
