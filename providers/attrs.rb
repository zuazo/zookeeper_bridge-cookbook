
action :read do
  if not new_resource.attribute.kind_of?(Chef::Node::VividMash)
    raise ArgumentError, "wrong node attribute: you should use writable node attributes like node.defaut[...] or node.normal[...]."
  end
  server = new_resource.server || node['chef-zki']['zookeeper']['server']
  zki = Chef::Zki.new(server)
  new_resource.updated_by_last_action(
    zki.attributes_read(new_resource.path, new_resource.attribute, new_resource.key) === true
  )
  zki.close
end

action :write do
  if not new_resource.attribute.kind_of?(Chef::Node::ImmutableMash)
    raise ArgumentError, "wrong node attribute: you should use readable node attributes like node[...]."
  end
  server = new_resource.server || node['chef-zki']['zookeeper']['server']
  zki = Chef::Zki.new(server)
  new_resource.updated_by_last_action(
    zki.attributes_write(new_resource.path, new_resource.attribute, new_resource.key) === true
  )
  zki.close
end

