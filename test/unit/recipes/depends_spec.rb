# encoding: UTF-8
#
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
#

require_relative '../spec_helper'

describe 'zookeeper_bridge::depends' do
  let(:version) { '7.7.7' }
  let(:chef_run) do
    ChefSpec::SoloRunner.new do |node|
      node.set['zookeeper_bridge']['chef_handler']['version'] = version
    end.converge(described_recipe)
  end

  it 'includes build-essential recipe' do
    expect(chef_run).to include_recipe('build-essential')
  end

  it 'installs zk gem' do
    expect(chef_run).to install_chef_gem('zk')
  end

  it 'installs chef-handler-zookeeper gem' do
    expect(chef_run).to install_chef_gem('chef-handler-zookeeper')
      .with_version(version)
  end
end
