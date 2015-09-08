# encoding: UTF-8
#
# Cookbook Name:: zookeeper_bridge_test
# Author:: Xabier de Zuazo (<xabier@zuazo.org>)
# Copyright:: Copyright (c) 2014 Onddo Labs, SL.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

name 'zookeeper_bridge_test'
maintainer 'Xabier de Zuazo'
maintainer_email 'xabier@zuazo.org'
license 'Apache 2.0'
description 'Installs/Configures zookeeper_bridge_test'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.1.0'

depends 'zookeeper', '~> 2.1'
depends 'zookeeper_bridge'
