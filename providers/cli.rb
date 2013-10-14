def whyrun_supported?
  true
end

action :run do
  command = new_resource.command.gsub(/\\/, '\\\\').gsub(/"/, '\\"') # TODO: a bit tricky
  cli = "#{node[:zookeeper][:install_dir]}/zookeeper-#{node[:zookeeper][:version]}/bin/zkCli.sh"
  sleep_prefix = if new_resource.sleep and new_resource.sleep > 0
    "sleep '#{new_resource.sleep.to_s}' && "
  else
    ''
  end
  background_sufix = new_resource.background ? ' &' : ''

  converge_by("Run zookeeper client command: #{command}") do
    execute "#{sleep_prefix}echo \"#{command}\" | '#{cli}'#{background_sufix}"
    # TODO: raise an exception if the zk command throws an error
  end
end

