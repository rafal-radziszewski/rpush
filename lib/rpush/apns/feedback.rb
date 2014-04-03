module Rpush
  module Apns
    class Feedback
      if Rpush.config.store == :active_record
        self.table_name = 'rpush_feedback'
      else
        include Mongoid::Document
        include Mongoid::Timestamps
        extend ActiveSupport::Concern
        
        store_in collection: 'rpush_feedback'
        
        field :device_token, type: String
        field :failed_at, type: DateTime
        field :app, type: String
        
        index({device_token: 1})
        index({app: 1})
      end

      if Rpush.attr_accessible_available?
        attr_accessible :device_token, :failed_at, :app
      end

      validates :device_token, :presence => true
      validates :failed_at, :presence => true

      validates_with Rpush::Apns::DeviceTokenFormatValidator
    end
  end
end
