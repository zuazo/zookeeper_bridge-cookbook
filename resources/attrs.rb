
actions :read, :write

attribute :path,      :kind_of => String, :name_attribute => true
attribute :server,    :kind_of => String, :default => '127.0.0.1:2181'
attribute :attribute, :kind_of => [ Chef::Node::VividMash, Hash ], :required => :true
attribute :key,       :kind_of => String, :default => 'attributes'

