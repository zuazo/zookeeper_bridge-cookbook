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
    context 'without merge' do
      let(:merge) { false }

      it 'reads without errors' do
        attr = { 'banana' => { 'apple' => 'orange' } }
        read = { 'dog' => { 'cow' => 'snake' } }
        allow(zkba).to receive(:zk_get_hash).and_return(read)
        expect(zkba.read('/path', attr, merge)).to eq(true)
      end

      it 'does not merge non-conflicting hashes' do
        attr = { 'banana' => { 'apple' => 'orange' } }
        read = { 'dog' => { 'cow' => 'snake' } }
        allow(zkba).to receive(:zk_get_hash).and_return(read)
        zkba.read('/path', attr, merge)
        expect(attr).to eq(read)
      end

      it 'does not merge conflicting hashes' do
        attr = { 'banana' => { 'apple' => 'orange' } }
        read = { 'banana' => { 'babaco' => 'canistel' } }
        allow(zkba).to receive(:zk_get_hash).and_return(read)
        zkba.read('/path', attr, merge)
        expect(attr).to eq(read)
      end
    end # context without merge

    context 'with merge' do
      let(:merge) { true }

      it 'reads without errors' do
        attr = { 'banana' => { 'apple' => 'orange' } }
        read = { 'dog' => { 'cow' => 'snake' } }
        allow(zkba).to receive(:zk_get_hash).and_return(read)
        expect(zkba.read('/path', attr, merge)).to eq(true)
      end

      it 'merges non-conflicting hashes' do
        attr = { 'banana' => { 'apple' => 'orange' } }
        read = { 'dog' => { 'cow' => 'snake' } }
        allow(zkba).to receive(:zk_get_hash).and_return(read)
        zkba.read('/path', attr, merge)
        expect(attr).to eq(
          'banana' => { 'apple' => 'orange' },
          'dog' => { 'cow' => 'snake' }
        )
      end

      it 'merges conflicting hashes' do
        attr = { 'banana' => { 'apple' => 'orange' } }
        read = { 'banana' => { 'babaco' => 'canistel' } }
        allow(zkba).to receive(:zk_get_hash).and_return(read)
        zkba.read('/path', attr, merge)
        expect(attr).to eq(
          'banana' => {
            'apple' => 'orange',
            'babaco' => 'canistel'
          }
        )
      end

      it 'read attributes have higher precedence' do
        attr = { 'banana' => { 'apple' => 'orange' } }
        read = { 'banana' => { 'apple' => 'canistel' } }
        allow(zkba).to receive(:zk_get_hash).and_return(read)
        zkba.read('/path', attr, merge)
        expect(attr).to eq(
          'banana' => { 'apple' => 'canistel' }
        )
      end
    end # context with merge
  end

  context '#write' do
    before do
      allow(zk).to receive(:exists?).with('/path').and_return(true)
      allow(zk).to receive(:set).and_return(true)
    end

    context 'without merge' do
      let(:merge) { false }

      it 'writes without errors' do
        attr = { 'banana' => { 'apple' => 'orange' } }
        read = { 'dog' => { 'cow' => 'snake' } }
        allow(zkba).to receive(:zk_get_hash).and_return(read)
        expect(zkba.write('/path', attr, merge)).to eq(true)
      end

      it 'does not change original hash' do
        attr = { 'banana' => { 'apple' => 'orange' } }
        read = { 'dog' => { 'cow' => 'snake' } }
        allow(zkba).to receive(:zk_get_hash).and_return(read)
        zkba.write('/path', attr, merge)
        expect(attr).to eq(attr)
      end

      it 'does not merge non-conflicting hashes' do
        attr = { 'banana' => { 'apple' => 'orange' } }
        read = { 'dog' => { 'cow' => 'snake' } }
        allow(zkba).to receive(:zk_get_hash).and_return(read)
        expect(zk).to receive(:set).with('/path', attr.to_json, anything)
        zkba.write('/path', attr, merge)
      end

      it 'does not merge conflicting hashes' do
        attr = { 'banana' => { 'apple' => 'orange' } }
        read = { 'banana' => { 'babaco' => 'canistel' } }
        allow(zkba).to receive(:zk_get_hash).and_return(read)
        expect(zk).to receive(:set).with('/path', attr.to_json, anything)
        zkba.write('/path', attr, merge)
      end
    end # context without merge

    context 'with merge' do
      let(:merge) { true }

      it 'writes without errors' do
        attr = { 'banana' => { 'apple' => 'orange' } }
        read = { 'dog' => { 'cow' => 'snake' } }
        allow(zkba).to receive(:zk_get_hash).and_return(read)
        expect(zkba.write('/path', attr, merge)).to eq(true)
      end

      it 'does not change original hash' do
        attr = { 'banana' => { 'apple' => 'orange' } }
        read = { 'dog' => { 'cow' => 'snake' } }
        allow(zkba).to receive(:zk_get_hash).and_return(read)
        zkba.write('/path', attr, merge)
        expect(attr).to eq(attr)
      end

      it 'merges non-conflicting hashes' do
        attr = { 'banana' => { 'apple' => 'orange' } }
        read = { 'dog' => { 'cow' => 'snake' } }
        allow(zkba).to receive(:zk_get_hash).and_return(read)
        expect(zk).to receive(:set).with('/path', {
          'dog' => { 'cow' => 'snake' },
          'banana' => { 'apple' => 'orange' }
        }.to_json, anything)
        zkba.write('/path', attr, merge)
      end

      it 'merges conflicting hashes' do
        attr = { 'banana' => { 'apple' => 'orange' } }
        read = { 'banana' => { 'babaco' => 'canistel' } }
        allow(zkba).to receive(:zk_get_hash).and_return(read)
        expect(zk).to receive(:set).with('/path', {
          'banana' => {
            'babaco' => 'canistel',
            'apple' => 'orange'
          }
        }.to_json, anything)
        zkba.write('/path', attr, merge)
      end

      it 'read attributes have lower precendence' do
        attr = { 'banana' => { 'apple' => 'orange' } }
        read = { 'banana' => { 'apple' => 'canistel' } }
        allow(zkba).to receive(:zk_get_hash).and_return(read)
        expect(zk).to receive(:set).with('/path', {
          'banana' => { 'apple' => 'orange' }
        }.to_json, anything)
        zkba.write('/path', attr, merge)
      end
    end # context with merge
  end
end
