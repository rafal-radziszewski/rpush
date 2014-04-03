require 'active_record'

# Can't find any other option to include all dependencies of ActiveRecord::Base
[Rpush::App, Rpush::Notification, Fpush::Apns::Feedback].each do |klass|
  klass.send :extend, ActiveModel::Naming

  klass.send :extend, ActiveSupport::Benchmarkable
  klass.send :extend, ActiveSupport::DescendantsTracker
    
  klass.send :extend, ActiveRecord::ConnectionHandling
  klass.send :extend, ActiveRecord::QueryCache::ClassMethods
  klass.send :extend, ActiveRecord::Querying
  klass.send :extend, ActiveRecord::Translation
  klass.send :extend, ActiveRecord::DynamicMatchers
  klass.send :extend, ActiveRecord::Explain
  
  klass.send :include, ActiveRecord::Persistence
  klass.send :include, ActiveRecord::ReadonlyAttributes
  klass.send :include, ActiveRecord::ModelSchema
  klass.send :include, ActiveRecord::Inheritance
  klass.send :include, ActiveRecord::Scoping
  klass.send :include, ActiveRecord::Sanitization
  klass.send :include, ActiveRecord::AttributeAssignment
  klass.send :include, ActiveModel::Conversion
  klass.send :include, ActiveRecord::Integration
  klass.send :include, ActiveRecord::Validations
  klass.send :include, ActiveRecord::CounterCache
  klass.send :include, ActiveRecord::Locking::Optimistic
  klass.send :include, ActiveRecord::Locking::Pessimistic
  klass.send :include, ActiveRecord::AttributeMethods
  klass.send :include, ActiveRecord::Callbacks
  klass.send :include, ActiveRecord::Timestamp
  klass.send :include, ActiveRecord::Associations
  klass.send :include, ActiveModel::SecurePassword
  klass.send :include, ActiveRecord::AutosaveAssociation
  klass.send :include, ActiveRecord::NestedAttributes
  klass.send :include, ActiveRecord::Aggregations
  klass.send :include, ActiveRecord::Transactions
  klass.send :include, ActiveRecord::Reflection
  klass.send :include, ActiveRecord::Serialization
  klass.send :include, ActiveRecord::Store
  klass.send :include, ActiveRecord::Core
end
