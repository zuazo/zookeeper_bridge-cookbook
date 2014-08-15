Description
===========
[![Cookbook Version](https://img.shields.io/cookbook/v/zookeeper_bridge.svg?style=flat)](https://supermarket.getchef.com/cookbooks/zookeeper_bridge)
[![Dependency Status](http://img.shields.io/gemnasium/onddo/zookeeper_bridge-cookbook.svg?style=flat)](https://gemnasium.com/onddo/zookeeper_bridge-cookbook)
[![Code Climate](http://img.shields.io/codeclimate/github/onddo/zookeeper_bridge-cookbook.svg?style=flat)](https://codeclimate.com/github/onddo/zookeeper_bridge-cookbook)
[![Build Status](http://img.shields.io/travis/onddo/zookeeper_bridge-cookbook.svg?style=flat)](https://travis-ci.org/onddo/zookeeper_bridge-cookbook)

Chef `zookeeper_bridge` cookbook, used to help integrating the *Chef Run* with ZooKeeper.

It can help in the following:

* Installing and running [Chef ZooKeeper Handler](http://onddo.github.io/chef-handler-zookeeper/).
* Reading or writing Chef Node attributes to and from ZooKeeper.
* Running ZooKeeper Client commands.
* Interacting with ZooKeeper read/write locks during the *Chef Run*.
* Interacting with ZooKeeper semaphores during the *Chef Run*.
* Wait until a ZooKeeper znode has the desired state or a certain event happens.

Some of the resources included in this cookbook have not been widely tested, so you should consider this cookbook as something **experimental**.

This cookbook is mainly used by calling the resources it provides. See their documentation below. The `zookeeper_bridge::default` recipe needs to be included before their use.

Requirements
============

## Platform Requirements

This cookbook has been tested on the following platforms:

* Amazon
* CentOS
* Debian
* Fedora
* RedHat
* Ubuntu

Please, [let us know](https://github.com/onddo/zookeeper_bridge-cookbook/issues/new?title=I%20have%20used%20it%20successfully%20on%20...) if you use it successfully on any other platform.

## Cookbook Requirements

* [build-essential](https://supermarket.getchef.com/cookbooks/build-essential) `~> 2.0`
* [chef_handler](https://supermarket.getchef.com/cookbooks/chef_handler)

## Application Requirements

* Ruby 1.9.3 or higher.
* `zk` ruby gem.

Attributes
==========

<table>
  <tr>
    <th>Attribute</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><code>node['zookeeper_bridge']['server']</code></td>
    <td>ZooKeeper server address.</td>
    <td><code>"127.0.0.1:2181"</code></td>
  </tr>
  <tr>
    <td><code>node['zookeeper_bridge']['chef_handler']['version']</code></td>
    <td><code>chef-handler-zookeeper</code> gem version to install.</td>
    <td><code>nil</code> <em>(latest)</em></td>
  </tr>
  <tr>
    <td><code>node['zookeeper_bridge']['chef_handler']['znode']</code></td>
    <td><code>chef-handler-zookeeper</code> znode path.</td>
    <td><code>"/chef/#{node['fqdn']}/status"</code></td>
  </tr>
</table>

Recipes
=======

## zookeeper_bridge::default

Minimum recipe required to use the providers.

## zookeeper_bridge::chef_handler

Installs and configures `chef-handler-zookeeper` gem.

## zookeeper_bridge::depends

Install some dependencies required by this cookbook.

Resources
=========

## zookeeper_bridge_rdlock[path]

Runs a [Read or Shared Lock](http://en.wikipedia.org/wiki/Readers%E2%80%93writer_lock) inside ZooKeeper. This resource is intended to be used together with the `zookeeper_bridge_wrlock` resource.

### zookeeper_bridge_rdlock actions

* `run`

### zookeeper_bridge_rdlock parameters

<table>
  <tr>
    <th>Parameter</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td>path</td>
    <td>Znode path.</td>
    <td><em>name</em></td>
  </tr>
  <tr>
    <td>server</td>
    <td>ZooKeeper server address.</td>
    <td><code>"127.0.0.1:2181"</code></td>
  </tr>
  <tr>
    <td>wait</td>
    <td>This can be an integer to wait a maximum of seconds and raise a timeout exception if this time is exceeded. By default is set to <code>true</code>, which will wait infinitely.</td>
    <td><code>true</code></td>
  </tr>
  <tr>
    <td>block</td>
    <td>The <em>recipe code</em> that will be run within the lock.</td>
    <td><code>nil</code></td>
  </tr>
</table>

### zookeeper_bridge_rdlock examples

```ruby
zookeeper_bridge_rdlock 'lock1' do
  server 'zk.example.com'
  block do
    # recipe code can be used here
    execute '...'
  end
end
```

Then you can use an exclusive lock from another node:

```ruby
zookeeper_bridge_wrlock 'lock1' do
  server 'zk.example.com'
  block do
    # recipe code can be used here
    execute '...'
  end
end
```

## zookeeper_bridge_wrlock[path]

Runs a [Write or Exclusive Lock](http://en.wikipedia.org/wiki/Readers%E2%80%93writer_lock) inside ZooKeeper. This resource is intended to be used together with the `zookeeper_bridge_rdlock` resource.

### zookeeper_bridge_wrlock actions

* `run`

### zookeeper_bridge_wrlock parameters

<table>
  <tr>
    <th>Parameter</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td>path</td>
    <td>Znode path.</td>
    <td><em>name</em></td>
  </tr>
  <tr>
    <td>server</td>
    <td>ZooKeeper server address.</td>
    <td><code>"127.0.0.1:2181"</code></td>
  </tr>
  <tr>
    <td>wait</td>
    <td>This can be an integer to wait a maximum of seconds and raise a timeout exception if this time is exceeded. By default is set to <code>true</code>, which will wait infinitely.</td>
    <td><code>true</code></td>
  </tr>
  <tr>
    <td>block</td>
    <td>The <em>recipe code</em> that will be run within the lock.</td>
    <td><code>nil</code></td>
  </tr>
</table>

### zookeeper_bridge_wrlock examples

The following block will only be running by a maximum of one node at a particular instant:

```ruby
zookeeper_bridge_wrlock 'lock1' do
  server 'zk.example.com'
  block do
    # recipe code can be used here
    execute '...'
  end
end
```

## zookeeper_bridge_sem[path]

Runs a [Semaphore](http://en.wikipedia.org/wiki/Semaphore_%28programming%29) inside ZooKeeper.

### zookeeper_bridge_sem actions

* `run`

### zookeeper_bridge_sem parameters

<table>
  <tr>
    <th>Parameter</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td>path</td>
    <td>Znode path.</td>
    <td><em>name</em></td>
  </tr>
  <tr>
    <td>server</td>
    <td>ZooKeeper server address.</td>
    <td><code>"127.0.0.1:2181"</code></td>
  </tr>
  <tr>
    <td>size</td>
    <td>Semaphore size: the maximum number of nodes that will be able to run the block at the same time.</td>
    <td><code>nil</code></td>
  </tr>
  <tr>
    <td>block</td>
    <td>The <em>recipe code</em> that will be run within the semaphore.</td>
    <td><code>nil</code></td>
  </tr>
  <tr>
    <td>wait</td>
    <td>This can be an integer to wait a maximum of seconds and raise a timeout exception if this time is exceeded. By default is set to <code>true</code>, which will wait infinitely.</td>
    <td><code>true</code></td>
  </tr>
</table>

### zookeeper_bridge_sem examples

You can call this from multiple nodes. The code within the following block will be running by a maximum of three nodes at the same time:

```ruby
zookeeper_bridge_sem 'sem1' do
  server 'zk.example.com'
  size 3
  block do
    # recipe code can be used here
    execute '...'
  end
end
```

## zookeeper_bridge_attrs[path]

Used to read or write Chef Node attributes from or to ZooKeeper znode paths. The attributes are saved into the znode using *JSON* format.

### zookeeper_bridge_attrs actions

* `read`: Read Node attributes from a znode.
* `write`: Write Node attributes to a znode.

### zookeeper_bridge_attrs parameters

<table>
  <tr>
    <th>Parameter</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td>path</td>
    <td>Znode path.</td>
    <td><em>name</em></td>
  </tr>
  <tr>
    <td>server</td>
    <td>ZooKeeper server address.</td>
    <td><code>node['zookeeper_bridge']['server']</code></td>
  </tr>
  <tr>
    <td>attribute</td>
    <td>Node attribute object or a Ruby Hash. This should be something like <code>node['foo']</code> for <strong>reading</strong> and <code>node.normal['foo']</code> for <strong>writing</strong>.</code></td>
    <td><code>nil</code></td>
  </tr>
  <tr>
    <td>key</td>
    <td>JSON sub-key to use for storing the attributes. This key is merged with the other JSON keys that currently exists in the znode. By default no key is used: attributes are at a root level JSON object.</td>
    <td><code>nil</code></td>
  </tr>
  <tr>
    <td>force_encoding</td>
    <td>Force character encoding. For example: <code>"UTF-8"</code>.</td>
    <td><code>nil</code></td>
  </tr>
</table>

### zookeeper_bridge_attrs examples

Reading and writing all node attributes from and to ZooKeeper:

```ruby
zookeeper_bridge_attrs "/chef/#{node['fqdn']}/read_attributes" do
  attribute node.normal
  action :nothing
end.run_action(:read)

# [...]

zookeeper_bridge_attrs "/chef/#{node['fqdn']}/write_attributes" do
  attribute node.attributes
  action :write
end
```

**Note:** You need to understand how [compile and converge phases work on Chef Run](http://docs.opscode.com/essentials_nodes_chef_run.html) to know when to use `#run_action`.

Reading and writing Apache attributes:

```ruby
# We use override in this case to overwrite default and normal values, why not?
zookeeper_bridge_attrs "/chef/#{node['fqdn']}/apache_attributes" do
  attribute node.override['apache']
  action :nothing
end.run_action(:read)

# [...]

zookeeper_bridge_attrs "/chef/#{node['fqdn']}/apache_attributes" do
  attribute node['apache']
  action :write
end
```

## zookeeper_bridge_wait[path]

Waits until a given ZooKeeper znode path exists, not exists or changes its state.

### zookeeper_bridge_wait actions

* `run`

### zookeeper_bridge_wait parameters

<table>
  <tr>
    <th>Parameter</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td>path</td>
    <td>Znode path.</td>
    <td><em>name</em></td>
  </tr>
  <tr>
    <td>server</td>
    <td>ZooKeeper server address.</td>
    <td><code>node['zookeeper_bridge']['server']</code></td>
  </tr>
  <tr>
    <td>status</td>
    <td>Wait until znode has this status. Possible values: <code>:any</code>, <code>:created</code> or <code>:deleted.</code>. <code>:any</code> means to ignore the status, normally used when the <code>event</code> parameter below is set.</td>
    <td><code>:any</code></td>
  </tr>
  <tr>
    <td>event</td>
    <td>Wait until specific znode event occurs. Possible values: <code>:none</code>, <code>:created</code>, <code>:deleted.</code>, <code>:changed</code>, <code>:child</code> or an array of multiple values. <code>:none</code> means to ignore the events, normally used when the <code>status</code> parameter is set. <code>:child</code> is for znode child events.</td>
    <td><code>:none</code></td>
  </tr>
</table>

### zookeeper_bridge_wait examples

Wait until host znode is created (at compile time, to avoid compilling the next resources):

```ruby
zookeeper_bridge_wait "/chef/#{node['fqdn']}" do
  status :created
  event :none
  action :nothing
end.run_action(:run)
```

Wait until the attributes exists before reading them:

```ruby
zookeeper_bridge_wait "/chef/#{node['fqdn']}/attributes" do
  status :created
  event :none
  action :nothing
end.run_action(:run)

zookeeper_bridge_attrs "/chef/#{node['fqdn']}/attributes" do
  attribute node.normal
  action :nothing
end.run_action(:read)
```

Continue the *Chef Run convergence* only when the *stop znode* does not exist:

```ruby
zookeeper_bridge_wait "/chef/#{node['fqdn']}/chef_stop" do
  status :deleted
  event :none
end
```

Continue the *Chef Run convergence* only when the *continue znode* is updated:

```ruby
zookeeper_bridge_wait "/chef/#{node['fqdn']}/chef_continue" do
  status :any
  event :changed
end
```

## zookeeper_bridge_cli[path]

Runs a ZooKeeper command using the `zkCli.sh` script. Remember that this script has some limitations.

### zookeeper_bridge_cli actions

* `run`: Runs a command.

### zookeeper_bridge_cli parameters

<table>
  <tr>
    <th>Parameter</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td>command</td>
    <td>ZooKeeper <code>zkCli.sh</code> command.</td>
    <td><em>name</em></td>
  </tr>
  <tr>
    <td>base_path</td>
    <td>ZooKeeper installation path.</td>
    <td><code>"#{node['zookeeper']['install_dir']}/zookeeper-#{node['zookeeper']['version']}"</code></td>
  </tr>
  <tr>
    <td>sleep</td>
    <td>Time to sleep in seconds before the command is run (type <code>Float</code>).</td>
    <td><code>nil</code></td>
  </tr>
  <tr>
    <td>background</td>
    <td>Whether to run the command in background.</td>
    <td><code>false</code></td>
  </tr>
</table>

### zookeeper_bridge_cli examples

```ruby
zookeeper_bridge_cli 'create /test some_random_data'
```

This resource is currently used in the integration tests. See the [zookeeper_bridge_test](https://github.com/onddo/zookeeper_bridge-cookbook/blob/master/test/cookbooks/zookeeper_bridge_test) cookbook recipes for more usage examples.

Testing
=======

See [TESTING.md](https://github.com/onddo/zookeeper_bridge-cookbook/blob/master/TESTING.md).

Contributing
============

Please do not hesitate to [open an issue](https://github.com/onddo/zookeeper_bridge-cookbook/issues/new) with any questions or problems.

See [CONTRIBUTING.md](https://github.com/onddo/zookeeper_bridge-cookbook/blob/master/CONTRIBUTING.md).

TODO
====

See [TODO.md](https://github.com/onddo/zookeeper_bridge-cookbook/blob/master/TODO.md).


License and Author
==================

|                      |                                          |
|:---------------------|:-----------------------------------------|
| **Author:**          | [Xabier de Zuazo](https://github.com/zuazo) (<xabier@onddo.com>)
| **Copyright:**       | Copyright (c) 2013-2014, Onddo Labs, SL. (www.onddo.com)
| **License:**         | Apache License, Version 2.0

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
