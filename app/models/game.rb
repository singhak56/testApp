class Game < ActiveRecord::Base
  # Modules
	require "rubygems"


 # Associations
  has_many :test


  # Callbacks
  after_create :create_pool
  
def self.register_player(name,msisdn,address)
	   sql = <<-SQL
		INSERT INTO t1 (name,msisdn,address) values('#{name}', '#{msisdn}', '#{address}')
      	   SQL
      connection.execute(sql)
end
end