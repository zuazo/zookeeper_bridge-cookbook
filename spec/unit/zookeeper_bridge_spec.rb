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

require 'spec_helper'
require 'zookeeper_bridge'
require 'zookeeper_bridge_depends'

describe Chef::ZookeeperBridge do
  let(:zkb) { described_class.new('127.0.0.1:2181') }
  before do
    allow(ZK).to receive(:new).and_return('ZK')
  end
  context '#path_to_name_and_root_node' do
    {
      '/chef/127.0.0.1' => %w(/chef 127.0.0.1),
      '/chef/127.0.0.1/status' => %w(/chef/127.0.0.1 status),
      '127.0.0.1' => [nil, '127.0.0.1'],
      '127.0.0.1/status' => [nil, '127.0.0.1/status']
    }.each do |path, value|
      it "returns #{value.inspect} from #{path}" do
        expect(zkb.path_to_name_and_root_node(path)).to eq(value)
      end
    end
  end
end
