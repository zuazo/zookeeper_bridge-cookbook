# encoding: UTF-8
#
# Author:: Xabier de Zuazo (<xabier@onddo.com>)
# Copyright:: Copyright (c) 2014 Onddo Labs, SL. (www.onddo.com)
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

require 'spec_helper'

# Fake class used to mock Gem and Gem::Specification classes
class FakeGemSpecification
  def lib_dirs_glob
    '/tmp/chef-handler-zookeeper'
  end

  def all_load_paths
    [lib_dirs_glob]
  end
end

describe 'zookeeper_bridge::chef_handler' do
  let(:chef_run) { ChefSpec::SoloRunner.new.converge(described_recipe) }
  before do
    if Gem::Specification.respond_to?('find_by_name')
      allow(Gem::Specification).to receive(:find_by_name)
        .with('chef-handler-zookeeper')
        .and_return(FakeGemSpecification.new)
    else
      allow(Gem).to receive(:all_load_paths)
        .and_return(FakeGemSpecification.new)
    end
  end

  it 'should include zookeeper_bridge::depends recipe' do
    expect(chef_run).to include_recipe('zookeeper_bridge::depends')
  end

  it 'should enable zookeeper chef handler' do
    source = "#{FakeGemSpecification.new.lib_dirs_glob}/chef/handler/zookeeper"
    expect(chef_run).to enable_chef_handler('Chef::Handler::ZookeeperHandler')
      .with_source(source)
  end

  it 'should trigget start handlers' do
    expect(chef_run).to run_ruby_block('trigger_start_handlers')
  end
end
