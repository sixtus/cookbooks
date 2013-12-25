actions :write
default_action :write

attribute :domain, kind_of: String, name_attribute: true, required: true
attribute :global, kind_of: [TrueClass, FalseClass], default: false
attribute :key, kind_of: String, default: nil
attribute :value, kind_of: [Integer, Float, String, TrueClass, FalseClass, Hash], default: nil, required: true
attribute :type, kind_of: String, default: nil
attribute :sudo, kind_of: [TrueClass, FalseClass], default: false
attribute :is_set, kind_of: [TrueClass, FalseClass], default: false
