class OTRS::Service < OTRS

  def self.set_accessor(key)
    attr_accessor key.to_sym
  end
  
  def persisted?
    false
  end
  
  def initialize(attributes = {})
    attributes.each do |name, value|
      OTRS::Service.set_accessor(name.to_s.underscore)
      send("#{name.to_s.underscore.to_sym}=", value)
    end
  end
  
  def self.find(id)
    params = "Object=ServiceObject&Method=ServiceGet&Data={\"ServiceID\":\"#{id}\",\"UserID\":\"1\"}"
    a = Hash[*connect(params)]
      if a.empty? == false
        self.new(a.symbolize_keys)
      else
        raise "ERROR::NoSuchID #{id}"
      end
  end
  
  def self.where(attributes)
    tmp = {}
    attributes.each do |key,value|
      tmp[key.to_s.camelize.to_sym] = value
    end
    attributes = tmp
    data = attributes.to_json
    params = "Object=ServiceObject&Method=ServiceSearch&Data=#{data}"
    a = connect(params)
    results = []
    a.each do |s|
     results << find(s)
    end
    results
  end

end