require 'sinatra'
require 'pry-byebug'

require_relative 'response'
require_relative 'commands'

def process_intent(request_json)
    session_id = request_json["session"]["id"]
    request_handler = request_json["handler"]["name"]

    logger.info "handler name: #{request_handler}"

    case request_handler
    when "connect"
        country_code = request_json["intent"]["params"]["selected_country"]["original"]
        logger.info "Connecting to #{country_code} VPN"
        Commands.connect_vpn(country_code)
        Response.output_speech(session_id, "VPN connected")

    when "reconnect"
        if Commands.reconnect_vpn
            return Response.output_speech(session_id, "Reconnected VPN")  
        else
            logger.info "Connection failed"
            return Response.output_speech(session_id, "Please connect to a VPN first")  
        end

    when "disconnect"
        Commands.disconnect
        return Response.output_speech(session_id, "VPN is now disconnected")

    else
        return Response.output_speech(session_id, "that didn't work")
    end
end

def connect_vpn(country_code, session_id, is_reconnect = false)
    connection_copy = is_reconnect ? "Reconnect" : "Connect"
    if Commands.connect_vpn(country_code, is_reconnect)
        logger.info "connect_vpn:if #{connection_copy}ed VPN to #{country_code}"
        return Response.output_speech(session_id, "VPN #{connection_copy}ed")
    else
        logger.info "connect_vpn:else #{connection_copy}ing to VPN failed"
        return Response.output_speech(session_id, "#{connection_copy}ing VPN to #{country} failed")
    end
end

post '/google_assistant' do
    logger.info "request received"
    request_json = JSON.parse request.body.string
    content_type :json
    output = process_intent(request_json)
    logger.info output
    output
end

post '/reset' do
    fork {
        Commands.reset_iptables
    }
    "iptables reset!"
end

get '/test' do
    logger.info "test route invoked"
    "GET: hello world"
end

post '/test' do
    system("sleep 5")
    return Response.output_speech("790797987", "FUCKED")
end