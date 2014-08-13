def server
  new_resource.server || node['zookeeper_bridge']['server']
end

action :read do
  unless new_resource.attribute.is_a?(Chef::Node::VividMash)
    fail ArgumentError, 'wrong node attribute: you should use writable node '\
      'attributes like node.defaut[...] or node.normal[...].'
  end
  zkb = Chef::ZookeeperBridge.new(server)
  new_resource.updated_by_last_action(
    zkb.attributes_read(
      new_resource.path,
      new_resource.attribute,
      new_resource.key,
      new_resource.force_encoding
    ) == true
  )
  zkb.close
end

action :write do
  if new_resource.attribute.is_a?(Chef::Node) ||
     new_resource.attribute.is_a?(Chef::Node::Attribute)
    attribute = new_resource.attribute.merged_attributes
  else
    attribute = new_resource.attribute
  end
  unless attribute.is_a?(Chef::Node::ImmutableMash)
    fail ArgumentError,
         "Wrong node attribute (#{attribute.class.name}): you should use "\
         'readable node attributes like node[...].'
  end
  zkb = Chef::ZookeeperBridge.new(server)
  new_resource.updated_by_last_action(
    zkb.attributes_write(
      new_resource.path,
      attribute,
      new_resource.key,
      new_resource.force_encoding
    ) == true
  )
  zkb.close
end
