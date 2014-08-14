# encoding: UTF-8

actions :read, :write

attribute :path, kind_of: String, name_attribute: true
attribute :server, kind_of: String, default: nil
attribute :attribute, kind_of: [Chef::Node::VividMash, Hash], required: true
attribute :key, kind_of: String, default: nil
attribute :force_encoding, kind_of: String, default: nil

def initialize(*args)
  super
  @action = :read
end
