
action :read do
  zki = Chef::Zki.new(new_resource.server)
  new_resource.updated_by_last_action(
    zki.attributes_read(new_resource.path, new_resource.attribute, new_resource.key) === true
  )
  zki.close
end

action :write do
  zki = Chef::Zki.new(new_resource.server)
  new_resource.updated_by_last_action(
    zki.attributes_write(new_resource.path, new_resource.attribute, new_resource.key) === true
  )
  zki.close
end

