actions :run

attribute :command, kind_of: String, name_attribute: true
attribute :sleep, kind_of: [Fixnum, Float], default: nil
attribute :background, kind_of: [TrueClass, FalseClass], default: FalseClass

def initialize(*args)
  super
  @action = :run
end
