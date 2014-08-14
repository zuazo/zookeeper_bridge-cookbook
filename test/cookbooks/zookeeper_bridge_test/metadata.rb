# encoding: UTF-8

name 'zookeeper_bridge_test'
maintainer 'Onddo Labs, Sl.'
maintainer_email 'team@onddo.com'
license 'Apache 2.0'
description 'Installs/Configures zookeeper_bridge_test'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.1.0'

depends 'zookeeper', '>= 2.1.1'
depends 'zookeeper_bridge'
