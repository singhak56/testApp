class Process < ActiveRecord::Base
  # Modules
  require 'base32/crockford'
  include ResultsProcessor
	require "rubygems"
	require "amqp"
  # Associations
  has_many :players
  has_many :levels
  has_one :pool

  # Callbacks
  after_create :create_pool


def processdata(name,msisdn,address)

AMQP.start(:host => "ubuntu1") do |connection|
channel = AMQP::Channel.new(connection)  
queue   = channel.queue("hello")  
channel.default_exchange.publish("Hello World!", :routing_key => queue.name)  
puts " [x] Sent 'Hello World!'"  
EM.add_timer(0.5) do    
connection.close do      
EM.stop { exit }    
end  
end
end
end

