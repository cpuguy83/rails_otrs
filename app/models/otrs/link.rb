class OTRS::Link < OTRS
  
  def self.set_accessors(key)
    attr_accessor key.to_sym
  end
  
  def initialize(attributes = {})
    attributes.each do |name, value|
      OTRS::Link.set_accessors(name.to_s.underscore)
      send("#{name.to_s.underscore.to_sym}=", value)
    end
  end
  
  def attributes
    attributes = {}
    self.instance_variables.each do |v|
      attributes[v.to_s.gsub('@','').to_sym] = self.instance_variable_get(v)
    end
    attributes
  end
  
  def save
    self.class.create(self.attributes)
  end
  
  def self.create(attributes)
    attributes[:state] ||= 'Valid'
    attributes[:user_id] ||= 1
    tmp = {}
    attributes.each do |key,value|
      if key == :user_id
        tmp[:UserID] = value
      end
      tmp[key.to_s.camelize.to_sym] = value
    end
    attributes = tmp
    data = attributes.to_json
    params = "Object=LinkObject&Method=LinkAdd&Data=#{data}"
    a = connect(params)
    if a.first == "1"
      self.where(attributes).first
    else
      raise "ERROR::FailedToCreateLinkObject"
    end
  end
  
  def self.where(attributes)
    # Returns list of link objects as Source => Target
    # Haven't decided if I want this to return the link object or what is being linked to
    attributes[:state] ||= 'Valid'
    tmp = {}
    attributes.each do |key,value|
      tmp[key.to_s.camelize.to_sym] = value
    end
    attributes = tmp
    data = attributes.to_json
    params = "Object=LinkObject&Method=LinkKeyList&Data=#{data}"
    a = connect(params)
    a = Hash[*a]
    b = []
    a.each do |key,value|
      c = {}
      c[:key2] = "#{key}"
      c[:object2] = attributes[:Object2]
      c[:object1] = attributes[:Object1]
      c[:key1] = attributes[:Key1]
      b << self.new(c)
    end
    b
  end
  
  def where(attributes)
    self.class.where(attributes)
  end

end