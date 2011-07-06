class EntryController < ApplicationController

  skip_before_filter :authenticate

  def input
    # Get data from params
    ##----------------------------------------------------------------------------------------------------------------#
    #msisdn =    params[:msisdn]
    #sms =       params[:message].split
    ##----------------------------------------------------------------------------------------------------------------#
    # Possible implementation if gateway provides configurable urls
    name =		   params[:NAME]
    msisdn =            params[:MSISDN]
    address =           params[:ADDRESS]
    if !address.blank?
      sms = address.split
    else
      sms = []
    end

    ##----------------------------------------------------------------------------------------------------------------#
        @response_message = name,msisdn,address
        #@process, @response_message = Process.processdata(name,msisdn,address)
        @game, @response_message = Game.register_player(name,msisdn,address)
      #  match_identifier = sms[0].downcase
    end
end
