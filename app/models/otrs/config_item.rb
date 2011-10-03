class OTRS::ConfigItem < OTRS
  
  def self.set_accessor(key)
    attr_accessor key.to_sym
  end
  
  def persisted?
    false
  end
  
  def initialize(attributes = {})
    attributes.each do |name, value|
      # cannot have numbers at beginning of field name
      if name =~ /^\d+/
        front_numbers = name[/^\d+/]
        name = name.gsub(/^\d+/,'') + front_numbers
      end
      if name =~ / /
        name = name.gsub(' ','_')
      end
      if name =~ /-/
        name = name.gsub('-','')
      end
      self.class.set_accessor(name)
      send("#{name.to_sym}=", value)
    end
  end
  
  def self.definition(definition_id)
    #params = "Object=ConfigItemObject&Method=DefinitionGet&Data={\"DefinitionID\":\"#{definition_id}\"}"
    data = { 'DefinitionID' => definition_id }
    params = { :object => 'ConfigItemObject', :method => 'DefinitionGet', :data => data }
    a = connect(params).first
  end
  
  def self.class_definition(class_id)
    #params = "Object=ConfigItemObject&Method=DefinitionGet&Data={\"ClassID\":\"#{class_id}\"}"
    data = { 'ClassID' => class_id }
    params = { :object => 'ConfigItemObject', :method => 'DefinitionGet', :data => data }
    a = connect(params).first.first.second.gsub(';','')
    ActiveSupport::JSON.decode(a)
    #a
  end
  
  def class_definition
    self.class.definition(self.ClassID)
  end
    
  def definition
    self.class.definition(self.DefinitionID)
  end
  
  
  def attributes
    attributes = {}
    self.instance_variables.each do |v|
      attributes[v.to_s.gsub('@','').to_sym] = self.instance_variable_get(v)
    end
    attributes
  end
  
  def save
    self.create(self.attributes)
  end
  
  def create(attributes)
    #params = "Object=ConfigItemObject&Method=ConfigItemAdd&Data={\"ClassID\":\"#{self.ClassID}\",\"UserID\":\"1\"}"
    data = { 'ClassID' => self.ClassID, 'UserID' => 1 }
    params = { :object => 'ConfigItemObject', :method => 'ConfigItemAdd', :data => data }
    a = self.class.connect(params)
    attributes[:ConfigItemID] = a.first
    attributes[:XMLData] = self.class.to_otrs_xml(attributes)
    data2 = attributes
    #params2 = "Object=ConfigItemObject&Method=VersionAdd&Data=#{data}"
    params2 = { :object => 'ConfigItemObject', :method => 'VersionAdd', :data => data2 }
    b = self.class.connect(params2)
    new_version_id = b.first
    config_item = self.class.find(attributes[:ConfigItemID])
    attributes = config_item.attributes
    attributes.each do |key,value|
      instance_variable_set "@#{key.to_s}", value
    end
    config_item
  end
  
  def self.where(attributes)
    tmp = {}
    attributes.each do |key,value|
      tmp[key.to_s.camelize.to_sym] = value
    end
    data = tmp
    #params = "Object=ConfigItemObject&Method=ConfigItemSearchExtended&Data=#{data}"
    params = { :object => 'ConfigItemObject', :method => 'ConfigItemSearchExtended', :data => data }
    a = connect(params).flatten
    results = []
    a.each do |b|
      results << find(b)
    end
    results
  end
  
  def self.to_otrs_xml(attributes)
    xml = attributes.except(:config_item_id,:Name,:DeplStateID,:InciStateID,:DefinitionID,
      :CreateTime,:ChangeBy,:ChangeTime,:Class,:ClassID,:ConfigItemID,:CreateBy,:CreateTime,
      :CurDeplState,:CurDeplStateID,:CurDeplStateType,:CurInciState,:CurInciStateID,:CurIncistateType,
      :DeplState,:DeplStateType,:InciState,:InciStateType,:LastVersionID,:Number,:VersionID)
    xml_hash = {}
    xml_data = [nil, { 'Version' => xml_hash }]
    tmp = []
    xml.each do |key,value|
      key = key.to_s
      tmp << key
    end
    # Order keys properly so they are parsed in the correct order
    tmp.sort! { |x,y| x <=> y }
    tmp.each do |key|
      if key =~ /__0\d+\Z/
        xml_key = key.gsub(/__0\d+\Z/,'').camelize
        tag_key = key[/__\d+\Z/][/\d+/].gsub(/^0/,'').to_i + 1
        if xml_hash[xml_key].nil?
          xml_hash[xml_key] = [nil] 
        end
        xml_hash[xml_key] << { "Content" => xml[key.to_sym] }
      elsif key =~ /__0\d+__/
        xml_key = key.split(/__\d+__/).first.camelize
        xml_subkey = key.split(/__\d+__/).second.camelize
        tag_key = key[/__\d+__/][/\d+/].gsub(/^0/,'').to_i + 1
        xml_hash[xml_key][tag_key][xml_subkey] = xml[key.to_sym]
      elsif key =~ /[a-z]__/
        xml_key = key.split('__').first.camelize
        xml_subkey = key.split('__').second.camelize
        if xml_hash[xml_key].nil? then xml_hash[xml_key] = [1] end
        xml_hash[xml_key][1][xml_subkey] = xml[key.to_sym]
      else
        xml_hash[key.camelize] = [ nil, { "Content" => xml[key.to_sym] }]
      end
    end
    xml_data
  end
  
  def update_attributes(updated_attributes)
    self.attributes.each do |key,value|
      if updated_attributes[key].nil?
        updated_attributes[key] = value
      end
    end
    updated_attributes[:XMLData] = self.class.to_otrs_xml(updated_attributes)
    data = updated_attributes
    #params = "Object=ConfigItemObject&Method=VersionAdd&Data=#{data}"
    params = { :object => 'ConfigItemObject', :method => 'VersionAdd', :data => data }
    a = self.class.connect(params)
    new_version_id = a.first
    #params2 = "Object=ConfigItemObject&Method=VersionConfigItemIDGet&Data={\"VersionID\":\"#{new_version_id}\"}"
    data = { 'VersionID' => new_version_id }
    params2 = { :object => 'ConfigItemObject', :method => 'VersionConfigItemIDGet', :data => data }
    b = self.class.connect(params2)
    config_item = self.class.find(b.first)
    attributes = config_item.attributes
    attributes.each do |key,value|
      instance_variable_set "@#{key.to_s}", value
    end
    config_item
  end
  
  def self.find(id)
    data = { 'ConfigItemID' => id }
    #params = "Object=ConfigItemObject&Method=ConfigItemGet&Data={\"ConfigItemID\":\"#{id}\"}"
    params = { :object => 'ConfigItemObject', :method => 'ConfigItemGet', :data => data }
    a = connect(params).first
    class_id = a["ClassID"]
    version_id = a["LastVersionID"]
    data2 = { 'ClassID' => class_id, 'VersionID' => version_id }
    #params2 = "Object=ConfigItemObject&Method=_XMLVersionGet&Data={\"ClassID\":\"#{class_id}\",\"VersionID\":\"#{version_id}\"}"
    params2 = { :object => 'ConfigItemObject', :method => '_XMLVersionGet', :data => data2 }
    b = connect(params2).first[1].flatten[1][1].except("TagKey")
    tmp = {}
    b.each do |key,value|
    # This chunk of code is parsing the data returned by the XML get
    # It has to first check and see if there are multiple entries for the same field name
    # If so it produces fields with a count tacked on the end so they can be properly tracked
    # From there it checks to see if there are custom fields within this field entry beyond just the main content
      b[key].delete(b[key][0])
      count = b[key].count
      if count == 1
        tmp[key] = value[count - 1]["Content"]
        count2 = value[count -1].except("Content","TagKey").count
        if count2 >= 1
          value[count -1].except("Content","TagKey").each do |key2,value2|
            value2.delete(value2[0])
            tmp["#{key}__#{key2}"] = value2[0]["Content"]
          end
        end
      else
        while count != 0
          tmp["#{key}__0#{count - 1}"] = value[count - 1]["Content"]
          count3 = value[count - 1].except("Content","TagKey").count
          if count3 > 1
            value[count - 1].except("Content","TagKey").each do |key3,value3|
              value3.delete(value3[0])
              tmp["#{key}__0#{count - 1}__#{key3}"] = value3[0]["Content"]
            end
          end
          count = count - 1
        end
      end
    end
    data3 = { 'ConfigItemID' => id, 'XMLDataGet' => 0 }
    #params3 = "Object=ConfigItemObject&Method=VersionGet&Data={\"ConfigItemID\":\"#{id}\",\"XMLDataGet\":\"0\"}"
    params3 = { :object => 'ConfigItemObject', :method => 'VersionGet', :data => data3 }
    c = connect(params3).first
    self.new(a.merge(c).merge(tmp))
  end
  
end