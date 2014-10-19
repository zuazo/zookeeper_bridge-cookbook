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
require 'zk'
require 'zookeeper_bridge'
require 'zookeeper_bridge_depends'
require 'zookeeper_bridge_attributes'

describe Chef::ZookeeperBridge::Attributes do
  let(:zkba) { described_class.new('127.0.0.1:2181') }
  # let(:zk) { instance_double('ZK') }
  let(:zk) { 'ZK' }
  before do
    allow(ZK).to receive(:new).and_return(zk)
  end

  context '#read' do

    it 'should merge without errors' do
      attr = { 'banana' => { 'apple' => 'orange' } }
      read = { 'dog' => { 'cow' => 'snake' } }
      allow(zkba).to receive(:zk_read_hash).and_return(read)
      expect(zkba.read('/path', attr)).to eq(true)
    end

    it 'should merge non-conflicting hashes' do
      attr = { 'banana' => { 'apple' => 'orange' } }
      read = { 'dog' => { 'cow' => 'snake' } }
      allow(zkba).to receive(:zk_read_hash).and_return(read)
      zkba.read('/path', attr)
      expect(attr).to eq(
        'banana' => { 'apple' => 'orange' },
        'dog' => { 'cow' => 'snake' }
      )
    end

    it 'should merge conflicting hashes' do
      attr = { 'banana' => { 'apple' => 'orange' } }
      read = { 'banana' => { 'babaco' => 'canistel' } }
      allow(zkba).to receive(:zk_read_hash).and_return(read)
      zkba.read('/path', attr)
      expect(attr).to eq(
        'banana' => {
          'apple' => 'orange',
          'babaco' => 'canistel'
        }
      )
    end

    it 'read attributes should have higher precedence' do
      attr = { 'banana' => { 'apple' => 'orange' } }
      read = { 'banana' => { 'apple' => 'canistel' } }
      allow(zkba).to receive(:zk_read_hash).and_return(read)
      zkba.read('/path', attr)
      expect(attr).to eq(
        'banana' => { 'apple' => 'canistel' }
      )
    end

  end

  context '#write' do
    before do
      allow(zk).to receive(:exists?).with('/path').and_return(true)
      allow(zk).to receive(:set).and_return(true)
    end

    it 'should merge without errors' do
      attr = { 'banana' => { 'apple' => 'orange' } }
      read = { 'dog' => { 'cow' => 'snake' } }
      allow(zkba).to receive(:zk_read_hash).and_return(read)
      expect(zkba.write('/path', attr)).to eq(true)
    end

    it 'should not change original hash' do
      attr = { 'banana' => { 'apple' => 'orange' } }
      read = { 'dog' => { 'cow' => 'snake' } }
      allow(zkba).to receive(:zk_read_hash).and_return(read)
      zkba.write('/path', attr)
      expect(attr).to eq(attr)
    end

    it 'should merge non-conflicting hashes' do
      attr = { 'banana' => { 'apple' => 'orange' } }
      read = { 'dog' => { 'cow' => 'snake' } }
      allow(zkba).to receive(:zk_read_hash).and_return(read)
      expect(zk).to receive(:set).with('/path', {
        'dog' => { 'cow' => 'snake' },
        'banana' => { 'apple' => 'orange' }
      }.to_json, anything)
      zkba.write('/path', attr)
    end

    it 'should merge conflicting hashes' do
      attr = { 'banana' => { 'apple' => 'orange' } }
      read = { 'banana' => { 'babaco' => 'canistel' } }
      allow(zkba).to receive(:zk_read_hash).and_return(read)
      expect(zk).to receive(:set).with('/path', {
        'banana' => {
          'babaco' => 'canistel',
          'apple' => 'orange'
        }
      }.to_json, anything)
      zkba.write('/path', attr)
    end

    it 'read attributes should have lower precendence' do
      attr = { 'banana' => { 'apple' => 'orange' } }
      read = { 'banana' => { 'apple' => 'canistel' } }
      allow(zkba).to receive(:zk_read_hash).and_return(read)
      expect(zk).to receive(:set).with('/path', {
        'banana' => { 'apple' => 'orange' }
      }.to_json, anything)
      zkba.write('/path', attr)
    end

  end
end
