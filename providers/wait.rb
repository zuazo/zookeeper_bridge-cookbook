
action :wait do
  zki = Chef::Zki.new(new_resource.server)
  case new_resource.status.to_sym
  when :created
    zki.block_until_znode_created(new_resource.path)
  when :deleted
    zki.block_until_znode_deleted(new_resource.path)
  end
  zki.block_until_znode_event(new_resource.path, new_resource.event) unless new_resource.event.to_sym == :none
  zki.close
end

