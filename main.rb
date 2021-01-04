require 'sinatra/base'
require 'pry-byebug'

require_relative 'commands'


class Main < Sinatra::Base
    configure do
        set :bind, '0.0.0.0'
    end

    get '/' do
        @is_connected, @country_code = Commands.nordvpn_status
        erb :index
    end

    post '/connect' do
        logger.info "request received"

        country = params["country"].upcase
        Commands.connect_vpn(country)

        content_type :json
        {"success": true, "country": country}.to_json
    end
    
    post '/disconnect' do
        Commands.disconnect

        content_type :json
        {"success": true}.to_json
    end

    run! if app_file == $0
end

