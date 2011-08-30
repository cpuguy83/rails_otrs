class OTRS::Link < OTRS
  
  def self.set_accessors(key)
    attr_accessor key.to_sym
  end
  
  def initialize(attributes = {})
    attributes.each do |name, value|
      OTRS::LinkObject.set_accessors(name.to_s.underscore)
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
    data = attributes.to_json
    params = "Object=LinkObject&Method=LinkKeyList&Data=#{data}"
    a = connect(params)
    a = Hash[*a]
    b = []
    a.each do |key,value|
      b << key
    end
    b
  end
  
end