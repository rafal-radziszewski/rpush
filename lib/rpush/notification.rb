module Rpush
  class Notification
    include Rpush::MultiJsonHelper
    
    if Rpush.config.store == :active_record  
      self.table_name = 'rpush_notifications'
      
      scope :ready_for_delivery, lambda {
        where('delivered = ? AND failed = ? AND (deliver_after IS NULL OR deliver_after < ?)',
              false, false, Time.now)
      }

      scope :for_apps, lambda { |apps|
        where('app_id IN (?)', apps.map(&:id))
      }

      scope :completed, lambda { where("delivered = ? OR failed = ?", true, true) }
      
      # TODO: Dump using multi json.
      serialize :registration_ids
      
    else
      include Mongoid::Document
      include Mongoid::Timestamps
      include Mongoid::Autoinc
      extend ActiveSupport::Concern
      
      store_in collection: 'rpush_notifications'
      
      field :badge, type: Integer
      field :device_token, type: String
      field :sound, type: String, default: "default"
      field :alert, type: String
      field :data, type: String
      field :expiry, type: Integer, default: 86400
      field :delivered, type: Boolean, default: false
      field :delivered_at, type: DateTime
      field :failed, type: Boolean, default: false
      field :failed_at, type: DateTime
      field :error_code, type: Integer
      field :error_description, type: String
      field :deliver_after, type: DateTime
      field :alert_is_json, type: Boolean, default: false
      field :type, type: String
      field :collapse_key, type: String
      field :delay_while_idle, type: Boolean, default: false
      field :registration_ids, type: Array
      field :retries, type: Integer, default: 0
      field :uri, type: String
      field :fail_after, type: DateTime
      field :validation_id, type: Integer
      
      increments :validation_id
      
      index({app_id: 1, delivered: -1, failed: -1, deliver_after: -1})
      index({delivered: -1, failed: -1, deliver_after: -1})
      index({validation_id: 1})
       
      scope :ready_for_delivery, lambda {
        where({"$and" => [delivered: false, failed: false, "$or" => [deliver_after: {"$ne" => nil}, deliver_after: {"$lt" => Time.now}]]})
      }
      
      scope :for_apps, lambda { |apps|
        where(app_id: {"$in" => apps.map(&:id)})
      }
      
      scope :completed, lambda { where("$or" => [{delivered: true}, {failed: true}]) }
    end

    belongs_to :app, :class_name => 'Rpush::App'

    if Rpush.attr_accessible_available?
      attr_accessible :badge, :device_token, :sound, :alert, :data, :expiry,:delivered,
        :delivered_at, :failed, :failed_at, :error_code, :error_description, :deliver_after,
        :alert_is_json, :app, :app_id, :collapse_key, :delay_while_idle, :registration_ids, :uri
    end

    validates :expiry, :numericality => true, :allow_nil => true
    validates :app, :presence => true

    def data=(attrs)
      return unless attrs
      raise ArgumentError, "must be a Hash" if !attrs.is_a?(Hash)
      write_attribute(:data, multi_json_dump(attrs.merge(data || {})))
    end

    def registration_ids=(ids)
      ids = [ids] if ids && !ids.is_a?(Array)
      super
    end

    def data
      multi_json_load(read_attribute(:data)) if read_attribute(:data)
    end

    def payload
      multi_json_dump(as_json)
    end

    def payload_size
      payload.bytesize
    end

    def payload_data_size
      multi_json_dump(as_json['data']).bytesize
    end

    class << self
      def created_before(dt)
        where("created_at < ?", dt)
      end

      def completed_and_older_than(dt)
        completed.created_before(dt)
      end
    end
  end
end
