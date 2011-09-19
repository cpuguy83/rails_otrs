class OTRS::ConfigItem < OTRS
  
  def self.set_accessor(key)
    attr_accessor key.to_sym
  end
  
  def persisted?
    false
  end
  
  def initialize(attributes = {})
    attributes.each do |name, value|
      OTRS::ConfigItem.set_accessor(name.to_s.underscore)
      send("#{name.to_s.underscore.to_sym}=", value)
    end
  end
  
  def self.where(attributes)
    terms = ""
    tmp = {}
    attributes.each do |key,value|
      tmp[key.to_s.camelize.to_sym] = value
    end
    attributes = tmp
    data = attributes.to_json
    params = "Object=ConfigItemObject&Method=ConfigItemSearchExtended&Data=#{data}"
    a = connect(params).flatten
    results = []
    a.each do |b|
      results << find(b)
    end
    results
  end
  
  def self.find(id)
    params = "Object=ConfigItemObject&Method=ConfigItemGet&Data={\"ConfigItemID\":\"#{id}\"}"
    a = connect(params).first
    class_id = a["ClassID"]
    version_id = a["LastVersionID"]
    params2 = "Object=ConfigItemObject&Method=_XMLVersionGet&Data={\"ClassID\":\"#{class_id}\",\"VersionID\":\"#{version_id}\"}"
    b = connect(params2)
    b = b.flatten
    b = b[1]
    b = b.first
    b = b.second
    b = b.second
    b = b.except("TagKey")
    b.each do |key,value|
      b[key] = value[1]["Content"]
    end
    self.new(a.merge(b))
  end
  
end