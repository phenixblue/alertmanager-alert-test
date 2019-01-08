#!/usr/bin/env ruby

##################################################################
#### MODULES #####################################################
##################################################################

require 'optparse'
require 'net/https'
require 'uri'
require 'io/console'

##################################################################
#### CONSTANTS / VARIABLES / ARRAYS / HASHES #####################
##################################################################

# -u,--url url_to_alertmanager
# -c,--context context_name
# -h,--help

$CONTEXT_NAME = ""
$BASE_URL = ""
$FULL_URL = ""

##################################################################
#### METHODS #####################################################
##################################################################

def getOptions(options) ####

    $stderr.sync = true

    # default options
    context_name = "cluster1"
    base_url = "k8s.example.com"
    full_url = "#{context_name}.#{base_url}"

    # parse arguments
    ARGV.options do |opts|

      opts.banner = "Usage: #{__FILE__} [options]"
      opts.separator ""
      opts.separator "Specific options:"

      opts.on("-u", "--url FULL_URL", "Specify the full URL for Alert Manager if the base domain is different than the default") do |val|

        full_url = val
        regex = /alertmanager\.(.*?)\.[example\.com|example\.org|example\.net]/
        context_name = "#{full_url.slice(regex, 1)}"

      end
      opts.on("-c", "--context CONTEXT_NAME", "Specify the context to work in. This assumes the default base domain: \"#{base_url}\"") do |val|

        context_name = val
        full_url = "alertmanager.#{context_name}.#{base_url}"

      end

      opts.on_tail("-h", "--help") do

        puts opts
        puts
        exit

      end

      opts.parse!

    end

    # DEBUG
    warn "ARGV:     #{ARGV.inspect}"
    warn "full_url:     #{full_url.inspect}"
    warn "context_name:     #{context_name.inspect}"

    puts "####################################################################"
    puts "Working Context: \"#{context_name}\""
    puts "Alert Manager URL: \"#{full_url}\""
    puts "####################################################################"
    puts

    $CONTEXT_NAME = "#{context_name}"
    $FULL_URL = "#{full_url}"

end #### getOptions


def continueNow

    puts "Press any key to resolve alert"
    STDIN.getch
    puts

end #### continueNow


def sendAlert(context, url) ####

    api_url = "https://#{url}"
    uri = URI.parse("#{api_url}/api/v1/alerts")
    rand_name = rand.to_s[2..10]

    puts "# Firing alert #{rand_name}"

    alert_json = "[{

      \"status\": \"firing\",
      \"labels\": {
        \"alertname\": \"Test Alert #{rand_name}\",
        \"service\": \"test-service\",
        \"severity\": \"warning\",
        \"instance\": \"test-instance\"
      },

      \"annotations\": {
        \"description\": \"This is a manual alert sent to validate operation of AlertManager.\",
        \"summary\": \"This is a Test Alert.\"
      },

      \"generatorURL\": \"#{url}/<generating_expression>\"

    }]"

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true if uri.scheme == 'https'
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    firing = Net::HTTP::Post.new(uri.request_uri, 'Content-Type' => 'application/json')
    firing.body = "#{alert_json}"

    response = http.request(firing)

    # DEBUG???
    puts
    puts "    - #{response.body}"
    puts

    continueNow

    puts "# Resolving alert #{rand_name}"

    alert_json = "[{

      \"status\": \"resolved\",
      \"labels\": {
        \"alertname\": \"Test Alert #{rand_name}\",
        \"service\": \"test-service\",
        \"severity\": \"warning\",
        \"instance\": \"test-instance\"
      },

      \"annotations\": {
        \"description\": \"This is a manual alert sent to validate operation of AlertManager.\",
        \"summary\": \"This is a Test Alert.\"
      },

      \"generatorURL\": \"#{url}/<generating_expression>\"

    }]"

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true if uri.scheme == 'https'
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    resolved = Net::HTTP::Post.new(uri.request_uri, 'Content-Type' => 'application/json')
    resolved.body = "#{alert_json}"

    response = http.request(resolved)

    # DEBUG???
    puts
    puts "    - #{response.body}"
    puts

end #### sendAlert

##################################################################
#### MAIN ########################################################
##################################################################

arrayOptions = getOptions(ARGV)
sendAlert($CONTEXT_NAME,$FULL_URL)

