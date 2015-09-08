# encoding: UTF-8
#
# Cookbook Name:: zookeeper_bridge
# Library:: matchers
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

if defined?(ChefSpec)

  [
    :zookeeper_bridge_attrs,
    :zookeeper_bridge_cli,
    :zookeeper_bridge_rdlock,
    :zookeeper_bridge_sem,
    :zookeeper_bridge_wait,
    :zookeeper_bridge_wrlock
  ].each do |matcher|
    if ChefSpec.respond_to?(:define_matcher)
      # ChefSpec >= 4.1
      ChefSpec.define_matcher matcher
    elsif defined?(ChefSpec::Runner) &&
          ChefSpec::Runner.respond_to?(:define_runner_method)
      # ChefSpec < 4.1
      ChefSpec::Runner.define_runner_method matcher
    end
  end

  def read_zookeeper_bridge_attrs(path)
    ChefSpec::Matchers::ResourceMatcher.new(
      :zookeeper_bridge_attrs,
      :read,
      path
    )
  end

  def write_zookeeper_bridge_attrs(path)
    ChefSpec::Matchers::ResourceMatcher.new(
      :zookeeper_bridge_attrs,
      :write,
      path
    )
  end

  def run_zookeeper_bridge_cli(command)
    ChefSpec::Matchers::ResourceMatcher.new(
      :zookeeper_bridge_cli,
      :run,
      command
    )
  end

  def run_zookeeper_bridge_rdlock(path)
    ChefSpec::Matchers::ResourceMatcher.new(
      :zookeeper_bridge_rdlock,
      :run,
      path
    )
  end

  def run_zookeeper_bridge_sem(path)
    ChefSpec::Matchers::ResourceMatcher.new(
      :zookeeper_bridge_sem,
      :run,
      path
    )
  end

  def run_zookeeper_bridge_wait(path)
    ChefSpec::Matchers::ResourceMatcher.new(
      :zookeeper_bridge_wait,
      :run,
      path
    )
  end

  def run_zookeeper_bridge_wrlock(path)
    ChefSpec::Matchers::ResourceMatcher.new(
      :zookeeper_bridge_wrlock,
      :run,
      path
    )
  end

end
