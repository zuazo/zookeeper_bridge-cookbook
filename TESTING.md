Testing
=======

### Cookbook Requirements

* [zookeeper](https://supermarket.getchef.com/cookbooks/zookeeper) `>= 2.1.1`

## Gem Requirements

* `vagrant`
* `foodcritic`
* `rubocop`
* `berkshelf`
* `chefspec`
* `test-kitchen`
* `kitchen-vagrant`

You must have [VirtualBox](https://www.virtualbox.org/) and [Vagrant](http://www.vagrantup.com/) installed.

You can install gem dependencies with bundler:

    $ gem install bundler
    $ bundle install

## Running the Syntax Style Tests

    $ bundle exec rake style

## Running the Unit Tests

    $ bundle exec rake unit

## Running the Integration Tests

    $ bundle exec rake integration

Or:

    $ bundle exec kitchen list
    $ bundle exec kitchen test
    [...]

### Running Integration Tests in the Cloud

#### Requirements:

* `kitchen-vagrant`
* `kitchen-digitalocean`
* `kitchen-ec2`

You can run the tests in the cloud instead of using vagrant. First, you must set the following environment variables:

* `AWS_ACCESS_KEY_ID`
* `AWS_SECRET_ACCESS_KEY`
* `AWS_KEYPAIR_NAME`: EC2 SSH public key name. This is the name used in Amazon EC2 Console's Key Pars section.
* `EC2_SSH_KEY_PATH`: EC2 SSH private key local full path. Only when you are not using an SSH Agent.
* `DIGITALOCEAN_CLIENT_ID`
* `DIGITALOCEAN_API_KEY`
* `DIGITALOCEAN_SSH_KEY_IDS`: DigitalOcean SSH numeric key IDs.
* `DIGITALOCEAN_SSH_KEY_PATH`: DigitalOcean SSH private key local full path. Only when you are not using an SSH Agent.

Then, you must configure test-kitchen to use `.kitchen.cloud.yml` configuration file:

    $ export KITCHEN_LOCAL_YAML=".kitchen.cloud.yml"
    $ bundle exec kitchen list
    [...]

## ChefSpec Matchers

### read_zookeeper_bridge_attrs(path)

Assert that the *Chef Run* reads `zookeeper_bridge_attrs`.

```ruby
expect(chef_run).to read_zookeeper_bridge_attrs("/chef/#{node['fqdn']}/attributes")
```

### write_zookeeper_bridge_attrs(path)

Assert that the *Chef Run* writes `zookeeper_bridge_attrs`.

```ruby
expect(chef_run).to write_zookeeper_bridge_attrs("/chef/#{node['fqdn']}/attributes")
```

### run_zookeeper_bridge_cli(command)

Assert that the *Chef Run* runs `zookeeper_bridge_cli`.

```ruby
expect(chef_run).to run_zookeeper_bridge_cli("create /test some_random_data")
```

### run_zookeeper_bridge_rdlock(path)

Assert that the *Chef Run* runs `zookeeper_bridge_rdlock`.

```ruby
expect(chef_run).to run_zookeeper_bridge_rdlock("my_lock")
```

### run_zookeeper_bridge_sem(path)

Assert that the Chef Run runs `zookeeper_bridge_sem`.

```ruby
expect(chef_run).to run_zookeeper_bridge_sem("my_semaphore")
  .with_size(1)
```

### run_zookeeper_bridge_wait(path)

Assert that the Chef run runs `zookeeper_bridge_wait`.

```ruby
# ensure waits until the attributes file exists
expect(chef_run).to run_zookeeper_bridge_wait("/chef/#{node['fqdn']}/attributes")
  .with_status(:created)
  .with_event(:none)
```

### run_zookeeper_bridge_wrlock(path)

Assert that the Chef run runs `zookeeper_bridge_wrlock`.

```ruby
expect(chef_run).to run_zookeeper_bridge_wrlock("my_lock")
```