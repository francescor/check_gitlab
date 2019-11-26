#!~/.rvm/rubies/ruby-2.3.4/bin/ruby
# (adapt the above to your ruby: `which ruby`)

require "nagios_check"
require 'json'
require 'net/http'

# check_gitlab.rb  --host mygitlab.xxx.com --port 7575  --uri '/-/readiness' -w 0 -c 1
# check_gitlab.rb  --host mygitlab.xxx.com --port 7575  --uri '/-/liveness' -w 0 -c 1
# check_gitlab.rb  --host mygitlab.xxx.com --port 7575  --uri '/-/health' -w 0 -c 1

class SimpleCheck
  include NagiosCheck

  on "--host HOST", "-H HOST", :mandatory
  on "--port PORT", "-P PORT", Integer, default: 80
  on "--uri URI",   "-U URI",  String,  default: '/-/liveness'

  enable_warning
  enable_critical
  enable_timeout

  def check
    number_of_fails = 0
    failure_descriptions = ''
    url = "http://#{options.host}:#{options.port}#{options.uri}"
    uri = URI(url)
    begin
      response = Net::HTTP.get(uri)
    rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
       Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError => e
    end
    if options.uri.split('/').last == 'health'
      # string response
      puts response
      if response[0..8] == 'GitLab OK'
        number_of_fails = 0
      else
        number_of_fails = 1
      end
      store_message = response
    else
      # json response 
      my_json = JSON.parse(response)
      my_json.keys.each do |key|
        if my_json[key].keys[0] = 'status'
          if my_json[key]['status'] == 'ok'
          else
            number_of_fails += 1
            failure_descriptions = "'#{key}' #{failure_descriptions}"
          end
        end
      end
      if number_of_fails == 0
        store_message "Full json: #{my_json}"
      else
        store_message "N. #{number_of_fails} failures on #{failure_descriptions} - Full json: #{my_json}"
      end
    end
    store_value :number_of_fails, number_of_fails
  end
end

SimpleCheck.new.run
