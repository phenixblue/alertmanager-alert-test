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
# -c,--context cluster_name
# -h,--help

$CLUSTER_NAME = ""
$BASE_URL = ""
$FULL_URL = ""
$USERNAME = "prometheus"
$PASSWORD = ""

##################################################################
#### METHODS #####################################################
##################################################################

def getOptions(options) ####

    $stderr.sync = true

    # default options
    cluster_name = "cluster1"
    base_url = "k8s.example.com"
    endpoint_url = "#{cluster_name}.#{base_url}"

    # parse arguments
    ARGV.options do |opts|

      opts.banner = "Usage: #{__FILE__} [options]"
      opts.separator ""
      opts.separator "Specific options:"

      opts.on("-e", "--endpoint ENDPOINT_URL", "Specify the full endpoint URL for Alert Manager if the base domain is different than the default") do |val|

        endpoint_url = val
        regex = /alertmanager\.(.*?)\.[example\.com|example\.org|example\.net]/
        cluster_name = "#{endpoint_url.slice(regex, 1)}"

      end
      opts.on("-c", "--cluster CLUSTER_NAME", "Specify the cluster to work in. This assumes the default base domain: \"#{base_url}\"") do |val|

        cluster_name = val
        endpoint_url = "alertmanager.#{cluster_name}.#{base_url}"

      end
      opts.on("-u", "--user USERNAME", "Specify the username of for the AlertManager Instance.") do |val|

        $USERNAME = val

      end

      opts.on_tail("-h", "--help") do

        puts opts
        puts
        exit

      end

      opts.parse!

    end

    # DEBUG
    #warn "ARGV:         #{ARGV.inspect}"
    #warn "endpoint_url:     #{endpoint_url.inspect}"
    #warn "cluster_name: #{cluster_name.inspect}"

    puts "####################################################################"
    puts "Working Cluster: \"#{cluster_name}\""
    puts "Alert Manager URL: \"#{endpoint_url}\""
    puts "####################################################################"
    puts

    $CLUSTER_NAME = "#{cluster_name}"
    $FULL_URL = "#{endpoint_url}"

end #### getOptions

def getPasswd ####

  puts "Enter Password for AlertManager user \"#{$USERNAME}\":"
  puts
  $PASSWORD = STDIN.noecho(&:gets).chomp

end #### getPassword

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
    firing.basic_auth("#{$USERNAME}","#{$PASSWORD}")

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
    resolved.basic_auth("#{$USERNAME}","#{$PASSWORD}")

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
getPasswd
sendAlert($CLUSTER_NAME,$FULL_URL)
