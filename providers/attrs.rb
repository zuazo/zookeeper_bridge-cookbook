
action :read do
  if not new_resource.attribute.kind_of?(Chef::Node::VividMash)
    raise ArgumentError, "wrong node attribute: you should use writable node attributes like node.defaut[...] or node.normal[...]."
  end
  zki = Chef::Zki.new(new_resource.server)
  new_resource.updated_by_last_action(
    zki.attributes_read(new_resource.path, new_resource.attribute, new_resource.key) === true
  )
  zki.close
end

action :write do
  if not new_resource.attribute.kind_of?(Chef::Node::ImmutableMash)
    raise ArgumentError, "wrong node attribute: you should use readable node attributes like node[...]."
  end
  zki = Chef::Zki.new(new_resource.server)
  new_resource.updated_by_last_action(
    zki.attributes_write(new_resource.path, new_resource.attribute, new_resource.key) === true
  )
  zki.close
end

