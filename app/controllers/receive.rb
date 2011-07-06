require "amqp"

AMQP.start(:host => "localhost") do |connection|  

channel = AMQP::Channel.new(connection)  

queue   = channel.queue("two")  

Signal.trap("INT") do    

connection.close do      

EM.stop { exit }    

end  
end  

# @OneToMany(mappedBy = "pool", fetch = FetchType.LAZY)
# @Cascade(CascadeType.ALL)

# @LazyCollection(LazyCollectionOption.EXTRA)
# @OrderBy("id")

# @OptimisticLock(excluded = true)
# @Enumerated(value = EnumType.STRING)


puts " [*] Waiting for messages. To exit press CTRL+C"  

queue.subscribe do |body|    

puts " [x] Received #{body}"  

# @response_message = name,msisdn,address
# process, @response_message = Process.processdata(name,msisdn,address)
# game, @response_message = Game.register_player(name,msisdn,address)
# match_identifier = sms[0].downcase

end
end

