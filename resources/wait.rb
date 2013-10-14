actions :wait

attribute :path,   :kind_of => String, :name_attribute => true
attribute :server, :kind_of => String, :default => '127.0.0.1:2181'
attribute :status, :equal_to => [ :any, :created, :deleted ], :default => :any
attribute :event,  :equal_to => [ :none, :created, :deleted, :changed, :child, Array ], :default => :none

def initialize(*args)
  super
  @action = :wait
end

