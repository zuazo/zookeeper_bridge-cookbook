CHANGELOG for zookeeper_bridge
===============================

This file is used to list changes made in each version of the `zookeeper_bridge` cookbook.

## v0.3.0 (2015-09-09)

* Install `tar` package.
* Update chef links to use *chef.io* domain.
* Update contact information and links after migration.
* metadata: Add `source_url` and `issues_url` links.
* Remove Fedora and RedHat support.

* Documentation:
 * Move ChefSpec matchers documentation to the README.
 * README:
  * Improve title and description.
  * Add GitHub badge.

* Testing:
 * Test files updates: Berksfile, Gemfile, Guardfile, Rakefile, RuboCop `0.34.0`.
 * Move ChefSpec tests to *test/unit*.
 * Travis CI: Run tests against Chef 11 and Chef 12.
 * .kitchen.yml: Update platform versions.
 * Use `runit` cookbook `1.6.0` to avoid issue [hw-cookbooks/runit#142](https://github.com/hw-cookbooks/runit/issues/142).

## v0.2.0 (2014-10-25)

* Add `zookeeper_bridge_attrs#merge` property.
* Remove `zookeeper_bridge_attrs#key` property (**breaking change**).
* Fix deep attribute merge in `zookeeper_bridge_attrs#read` (**breaking change**).
* Fix deep attribute merge in `zookeeper_bridge_attrs#write` (**breaking change**).
* `ZooKeeperBridge::Attributes`: fix encoding force on write.
* Fix a RuboCop offense.
* Set `apt` cookbook compile time update.
* Add rubocop.yml file.
* Use a descriptive name in unit tests instead of subject.
* Integrate tests with `should_not` gem.
* ChefSpec matchers: Add helper methods to locate LWRP resources.
* Update to ChefSpec `4.1`.
* Update to Berkshelf `3.1`.
* Use generic Berksfile template.
* travis.yml: exclude some gemfile groups.
* Rakefile:
 * Include `kitchen` gem only if required.
  * Add documentation link.
* Refactor Gemfile to use style, unit and integration groups.
* Add Guardfile.
* Documentation: use single quotes in examples.
* README:
 * Fix apache attributes example.
 * Fix some typos.
 * Use markdown tables.
* TODO: use checkboxes.
* TESTING.md:
 * Some improvements.
 * Update to use Digital Ocean Access Token.
* Homogenize license headers.
* kitchen.yml update.
* kitchen.cloud.yml: use one line run_list to include apt cookbook.

## v0.1.0 (2014-08-18)

* Initial release of `zookeeper_bridge`.
