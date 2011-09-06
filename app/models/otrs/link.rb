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
  
  def create(source_object_class, source_object_key, target_object_class, target_object_key, type)
    params = "Object=LinkObject&Method=LinkAdd&Data={\"SourceObject\":\"#{source_object_class}\",\"SourceKey\":\"#{source_object_key}\",\"TargetObject\":\"#{target_object_class}\",\"TargetKey\":\"#{target_object_key}\",\"Type\":\"#{type}\",\"State\":\"Valid\",\"UserID\":\"1\"}"
    a = connect(params)
    if a.first == "1"
      @attributes = {"Source" => source_object_key, "Target" => target_object_key}
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
  
end