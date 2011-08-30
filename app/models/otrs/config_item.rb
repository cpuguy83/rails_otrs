class OTRS::ConfigItem < OTRS
  
  def self.where(attributes)
    terms = ""
    attributes.each do |key,value|
      terms = "\"#{key}\":\"#{value}\"," + terms
    end
    params = "Object=ConfigItem&Method=ConfigItemSearchExtended&Data={#{terms.gsub(/,$/,'')}}"
    a = connect(params).flatten
    results = []
    a.each do |f|
      results << find(f)
    end
    results
  end
  
  def self.find(id)
    params = "Object=ConfigItem&Method=ConfigItemGet&Data={\"ConfigItemID\":\"#{id}\"}"
    a = connect(params).first
    class_id = a["ClassID"]
    version_id = a["LastVersionID"]
    params2 = "Object=ConfigItem&Method=_XMLVersionGet&Data={\"ClassID\":\"#{class_id}\",\"VersionID\":\"#{version_id}\"}"
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
    a.merge(b)
  end
  
  def find(id)
    params = "Object=ConfigItem&Method=ConfigItemGet&Data={\"ConfigItemID\":\"#{id}\"}"
    a = connect(params).first
    class_id = a["ClassID"]
    version_id = a["LastVersionID"]
    params2 = "Object=ConfigItem&Method=_XMLVersionGet&Data={\"ClassID\":\"#{class_id}\",\"VersionID\":\"#{version_id}\"}"
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
    a.merge(b)
  end
  
end