Description
===========

Chef `zookeeper-bridge` cookbook, used to help integrating the Chef Run with ZooKeeper.

This cookbook is mainly used by calling the Resources it provides. See their documentation below. The `zookeeper-bridge::default` recipe needs to be included before its use.

Requirements
============

## Platform:

* Debian
* Ubuntu
* Centos

## Cookbooks:

* build-essential
* chef_handler

## Ruby gems

* zk

Attributes
==========

<table>
  <tr>
    <td>Attribute</td>
    <td>Description</td>
    <td>Default</td>
  </tr>
  <tr>
    <td><code>node['zookeeper-bridge']['zookeeper']['server']</code></td>
    <td>Zookeeper server address.</td>
    <td><code>"127.0.0.1:2181"</code></td>
  </tr>
</table>

Recipes
=======

## zookeeper-bridge::default

Minimum recipe required to use the providers.

## zookeeper-bridge::depends

Install some dependencies required by this cookbook.

## zookeeper-bridge::zookeeper_handler

Installs and configures `chef-handler-zookeeper` gem.

Resources
=========

## zookeeper_bridge_attrs[path]

Used to read or write Chef Node attributes from or to ZooKeeper znode paths. The attributes are saved into the znode using JSON format.

### zookeeper_bridge_attrs actions

* `read`: Read Node attributes from a znode.
* `write`: Write Node attributes to a znode.

### zookeeper_bridge_attrs attributes

<table>
  <tr>
    <th>Attribute</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td>path</td>
    <td>Znode path</td>
    <td><em>name</em></td>
  </tr>
  <tr>
    <td>server</td>
    <td>ZooKeeper server address.</td>
    <td><code>node['zookeeper-bridge']['zookeeper']['server']</code></td>
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
    <td>Force character encoding. For example: <code>"UTF-8"</code></td>
    <td><code>nil</code></td>
  </tr>
</table>

### zookeeper_bridge_attrs example

```ruby
# Reading/Writing all node attributes

hostname = `hostname`.chomp

zookeeper_bridge_attrs "/chef/#{hostname}/read_attributes" do
  attribute node.normal
  action :nothing
end.run_action(:read)

# [...]

zookeeper_bridge_attrs "/chef/#{hostname}/write_attributes" do
  attribute node.attributes
  action :write
end
```

**Note:** You need to understand how [compile and converge phases work on Chef Run](http://docs.opscode.com/essentials_nodes_chef_run.html) to know when to use `run_action()`.

```ruby
# Reading/Writing Apache attributes

hostname = `hostname`.chomp

zookeeper_bridge_attrs "/chef/#{hostname}/read_attributes" do
  attribute node.normal['apache']
  action :nothing
end.run_action(:read)

# [...]

zookeeper_bridge_attrs "/chef/#{hostname}/write_attributes" do
  attribute node['apache']
  action :write
end
```

## zookeeper_bridge_wait[path]

Waits until a given ZooKeeper znode path exists, not exists or changes its state.

### zookeeper_bridge_wait actions

* `wait`

### zookeeper_bridge_wait attributes

<table>
  <tr>
    <th>Attribute</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td>path</td>
    <td>Znode path</td>
    <td><em>name</em></td>
  </tr>
  <tr>
    <td>server</td>
    <td>ZooKeeper server address.</td>
    <td><code>node['zookeeper-bridge']['zookeeper']['server']</code></td>
  </tr>
  <tr>
    <td>status</td>
    <td>Wait until znode has this status. Possible values: <code>:any</code>, <code>:created</code> or <code>:deleted.</code>. <code>:any</code> means to ignore the status, used when the <code>event</code> attribute below is set.</td>
    <td><code>:any</code></td>
  </tr>
  <tr>
    <td>event</td>
    <td>Wait until specific znode event occurs. Possible values: <code>:none</code>, <code>:created</code>, <code>:deleted.</code>, <code>:changed</code>, <code>:child</code> or an array of multiple values. <code>:none</code> means to ignore the events, used when the <code>status</code> attribute is set. <code>:child</code> is for znode child events.</td>
    <td><code>:none</code></td>
  </tr>
</table>

### zookeeper_bridge_wait example

```ruby
# wait until hostname znode is created
hostname = `hostname`.chomp
zookeeper_bridge_wait "/chef/#{hostname}" do
  status :created
  event :none
  action :nothing
end.run_action(:wait)
```

## zookeeper_bridge_cli[path]

Runs a ZooKeeper command using the `zkCli.sh` script. Remember that this script has some limitations.

### zookeeper_bridge_cli actions

* `run`: Runs a command.

### zookeeper_bridge_cli attributes

<table>
  <tr>
    <th>Attribute</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td>command</td>
    <td>ZooKeeper <code>zkCli.sh</code> command.</td>
    <td><em>name</em></td>
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

### zookeeper_bridge_cli example

```ruby
zookeeper_bridge_cli 'create /test some_random_data'
```

This resource is currently used in the integration tests. See the `zookeeper-bridge_test` cookbook recipes for more usage examples.

Testing
=======

## Requirements

* `vagrant`
* `berkshelf`
* `test-kitchen` >= `1.0.0.beta.1`
* `kitchen-vagrant`

## Running the tests

```bash
$ kitchen test
$ kitchen verify
[...]
```

Contributing
============

1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write you change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github


License and Author
=====================

|                      |                                          |
|:---------------------|:-----------------------------------------|
| **Author:**          | Xabier de Zuazo (<xabier@onddo.com>)
| **Copyright:**       | Copyright (c) 2013 Onddo Labs, SL. (www.onddo.com)
| **License:**         | Apache License, Version 2.0

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

