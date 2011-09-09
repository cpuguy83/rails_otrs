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
    
    attributes.each do |key,value|
      if key == :user_id
        attributes[:UserID] = value
      end
      attributes[key.to_s.camelize.to_sym] = value
      attributes.delete(key.to_s.underscore.to_sym)
    end
    
    data = attributes.to_json
    params = "Object=LinkObject&Method=LinkAdd&Data=#{data}"
    a = connect(params)
    if a.first == "1"
      self.where(attributes).first
    else
      raise "ERROR::FailedToCreateObject"
    end
  end
  
  def self.where(attributes)
    # Returns list of link objects as Source => Target
    # Haven't decided if I want this to return the link object or what is being linked to
    attributes.each do |key,value|
      attributes[key.to_s.camelize.to_sym] = value
      attributes.delete(key.to_s.underscore.to_sym)
    end
    data = attributes.to_json
    params = "Object=LinkObject&Method=LinkKeyList&Data=#{data}"
    a = connect(params)
    a = Hash[*a]
    b = []
    a.each do |key,value|
      c = {}
      c[:target_id] = "#{key}"
      c[:target_object] = attributes[:Object2]
      c[:source_object] = attributes[:Object1]
      c[:source_id] = attributes[:Key1]
      b << self.new(c)
    end
    b
  end
  
  def where(attributes)
    self.class.where(attributes)
  end

end