require "rubygems"
require "amqp"

AMQP.start(:host => "ubuntu1") do |connection|

channel = AMQP::Channel.new(connection)  

queue   = channel.queue("firstQ")  
queue   = channel.queue("secondQ")  

channel.default_exchange.publish("Hello World!", :routing_key => queue.name)  

puts " [x] Sent 'Hello World!'"  

EM.add_timer(0.5) do    

connection.close do      

EM.stop { exit }    

# @response_message = name,msisdn,address
# process, @response_message = Process.processdata(name,msisdn,address)
# game, @response_message = Game.register_player(name,msisdn,address)
# match_identifier = sms[0].downcase

end  
end
end