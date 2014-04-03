module Rpush
  class App #< ActiveRecord::Base
    
    if Rpush.config.store == :active_record
      self.table_name = 'rpush_apps'
    else
      include Mongoid::Document
      include Mongoid::Timestamps
      extend ActiveSupport::Concern
      
      store_in collection: 'rpush_apps'
      
      field :name,                    type: String  
      field :environment,             type: String  
      field :certificate,             type: String  
      field :password,                type: String  
      field :connections,             type: Integer, default: 1
      field :type,                    type: String  
      field :auth_key,                type: String  
      field :client_id,               type: String  
      field :client_secret,           type: String  
      field :access_token,            type: String  
      field :access_token_expiration, type: DateTime
      
      index({name: 1})
    end

    if Rpush.attr_accessible_available?
      attr_accessible :name, :environment, :certificate, :password, :connections, :auth_key, :client_id, :client_secret
    end

    has_many :notifications, :class_name => 'Rpush::Notification', :dependent => :destroy

    validates :name, :presence => true, :uniqueness => { :scope => [:type, :environment] }
    validates_numericality_of :connections, :greater_than => 0, :only_integer => true

    def service_name
      raise NotImplementedError
    end
  end
end
