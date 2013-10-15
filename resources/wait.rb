actions :wait

attribute :path,   :kind_of => String, :name_attribute => true
attribute :server, :kind_of => String, :default => nil
attribute :status, :equal_to => [ :any, :created, :deleted ], :default => :any
attribute :event,  :equal_to => [ :none, :created, :deleted, :changed, :child, Array ], :default => :none

def initialize(*args)
  super
  @action = :wait
end

