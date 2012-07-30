require 'rubygems'
require "net/https"
require "uri"
require 'openssl'

class Viximo
  def initialize(api_key, api_secret)
    @key = api_key
    @secret = api_secret
    @uri = "https://api.socialzone.viximo.com"
  end
  
  #params is a hash with request parameters we want to send and their values
  #updating to "message from app" api
  def send_message(params)
    uri = URI.parse(@uri)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    parameters = ""
    params.each do |k,v|
      if parameters.empty?
        parameters = "#{k}=#{v}"
      else
        parameters += "&#{k}=#{v}"
      end
    end
    sig = generate_signature(params)
    parameters += "&signature=#{sig}"
    puts parameters 
    response = http.post("/api/2/apps/#{@key}/messages.json", "#{URI.escape(parameters)}")
    puts response
    return response.body
  end

  def broadcast(params)
    uri = URI.parse(@uri)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    parameters = ""
    params.each do |k,v|
      if parameters.empty?
        parameters = "#{k}=#{v}"
      else
        parameters += "&#{k}=#{v}"
      end
    end
    parameters += "&signature=#{generate_signature(params)}"

    response = http.post("/api/2/apps/#{@key}/broadcast_notifications.json", "#{URI.escape(parameters)}")
    return response.body
  end

  def generate_signature(params)
    value_string = ""
    params.keys.sort.each do |key|
      value_string += params[key].to_s
    end
    signature = OpenSSL::HMAC.hexdigest('sha256',@secret,value_string)
    return signature
  end
end
