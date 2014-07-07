name             'zookeeper_bridge'
maintainer       'Onddo Labs, Sl.'
maintainer_email 'team@onddo.com'
license          'Apache 2.0'
description      'Chef zookeeper_bridge cookbook, used to help integrating the Chef Run with ZooKeeper.'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

supports 'debian'
supports 'ubuntu'
supports 'centos'

depends 'build-essential', '~> 2.0'
depends 'chef_handler'

recipe 'zookeeper_bridge::default', 'Minimum recipe required to use the providers.'
recipe 'zookeeper_bridge::depends', 'Install some dependencies required by this cookbooks.'
recipe 'zookeeper_bridge::zookeeper_handler', 'Installs and configures chef-handler-zookeeper.'

attribute 'zookeeper_bridge/zookeeper/server',
  :display_name => 'zookeeper server',
  :description => 'Zookeeper server address.',
  :type => 'string',
  :required => 'optional',
  :default => '"127.0.0.1:2181"'

provides 'zookeeper_bridge_attrs'
provides 'zookeeper_bridge_cli'
provides 'zookeeper_bridge_wait'

