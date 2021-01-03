require 'open3'
require 'pry-byebug'

class Commands
    CLIENTS = [
        "192.168.1.11",
        "192.168.1.2"
    ]

    def self.connect_vpn(country)
        is_connected, _ = nordvpn_status
        is_connected_binary = is_connected ? 1 : 0

        cmd = './connect.sh -c' + country + ' -r ' + is_connected_binary.to_s + ' -i "' + CLIENTS.join(';') + '"'
        puts cmd
        fork {
            exec(cmd)
        }
    end

    def self.reconnect_vpn
        is_reconnect, country = nordvpn_status
        if is_reconnect
            fork {
                exec("nordvpn connect #{country}")
            }
        else
            return false
        end
        return true
    end

    def self.disconnect
        fork {
            exec("./reset.sh")
        }
    end

    def self.nordvpn_status
        stdout, stderr, status = Open3.capture3("nordvpn status")
        is_connected = stdout.gsub("\r", "").split("\n")[0].include? "Status: Connected"

        country_url = stdout.gsub("\r", "").split("\n")[1]
        country_code_capture = country_url.match(/([a-z]{1,4})\d{1,4}.nordvpn.com/).captures[0] if country_url
        country_code = country_code_capture.upcase if country_code_capture
        return is_connected, country_code
    end
end