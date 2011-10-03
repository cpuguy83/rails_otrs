class OTRS
  include ActiveModel::Conversion
  include ActiveModel::Naming
  include ActiveModel::Validations

  
  # @@otrs_host is the address where the OTRS server presides
  @@otrs_host = 'localhost'
  # api_url is the base URL used to connect to the json api of OTRS, this will be the custom json.pl as the standard doesn't include ITSM module
  @@otrs_api_url = "https://#{@@otrs_host}/otrs/json.pl"
  # Username / password combo should be an actual OTRS agent defined on the OTRS server
  # I have not tested this with other forms of OTRS authentication
  @@otrs_user = 'rails'
  @@otrs_pass = 'rails'
  
  def self.user
    @@otrs_user
  end
  
  def self.password
    @@otrs_pass
  end
  
  def self.host
    @@otrs_host
  end
  
  def self.api_url
    @@otrs_api_url
  end
  
  def self.connect(params)
    require 'net/https'
    base_url = self.api_url
    logon = URI.encode("User=#{self.user}&Password=#{self.password}")
    object = URI.encode(params[:object])
    method = URI.encode(params[:method])
    data = params[:data].to_json
    data = URI.escape(data, '{}[]: &"')
    uri = URI.parse("#{base_url}?#{logon}&Object=#{object}&Method=#{method}&Data=#{data}")

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
    result = ActiveSupport::JSON::decode(response.body)
    if result["Result"] == 'successful'
      result["Data"]
    else
      raise "Error:#{result["Result"]} #{result["Data"]}"
    end
  end
  
  def connect(params)
    self.class.connect(params)
  end
end