actions :run

attribute :path, kind_of: String, name_attribute: true
attribute :server, kind_of: String, default: nil
attribute :size, kind_of: Integer, required: true
attribute :wait, kind_of: [TrueClass, Integer], default: true

def block(&block)
  if block_given? && block
    @block = block
  else
    @block
  end
end

def initialize(*args)
  super
  @action = :run
end
