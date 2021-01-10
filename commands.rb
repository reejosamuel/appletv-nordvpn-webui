require 'open3'
require 'pry-byebug'

class Commands
    CLIENTS = [
        "192.168.1.11",
        "192.168.1.2"
    ]
    PWD = File.expand_path(File.dirname(__FILE__))

    def self.connect_vpn(country)
        cmd = PWD + '/connect.sh -c' + country + ' -i "' + CLIENTS.join(';') + '"'
        system(cmd)
    end

    def self.disconnect
        system(PWD + "/reset.sh")
    end

    def self.nordvpn_status
        stdout, stderr, status = Open3.capture3("nordvpn status")
        is_connected = stdout.gsub("\r", "").split("\n")[0].include? "Status: Connected"

        country_url = stdout.gsub("\r", "").split("\n")[1]
        country_code_match = country_url.match(/([a-z]{1,4})\d{1,4}.nordvpn.com/) if country_url
        country_code_capture = country_code_match.captures[0] if country_code_match
        country_code = country_code_capture.upcase if country_code_capture
        return is_connected, country_code
    end
end
