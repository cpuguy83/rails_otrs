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
      unless name =~ /^\d+/ or name =~ / / or name =~ /-/
        self.class.set_accessor(name)
        send("#{name.to_sym}=", value)
      end
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
    xml = attributes.except(:Name,:DeplStateID,:InciStateID,:DefinitionID,
      :CreateTime,:ChangeBy,:ChangeTime,:Class,:ClassID,:ConfigItemID,:CreateBy,:CreateTime,
      :CurDeplState,:CurDeplStateID,:CurDeplStateType,:CurInciState,:CurInciStateID,:CurInciStateType,
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
      keys = key.split(/__/)
      xml_key = keys[0]
      unless keys[1].nil? then tag_key = keys[1].gsub(/^0/,'').to_i + 1 end
      xml_subkey = keys[2]
      case key
      when /^[aA-zZ]+__0\d+__[aA-zZ]+__0\d+$/
        if xml_hash[xml_key][tag_key][xml_subkey].nil?
          xml_hash[xml_key][tag_key][xml_subkey] = [nil, { "Content" => xml[key.to_sym] }]
        else
          xml_hash[xml_key][tag_key][xml_subkey] << { "Content" => xml[key.to_sym] }
        end
      when /^[aA-zZ]+__0\d+__[aA-zZ]$/
        xml_hash[xml_key][tag_key][xml_subkey] = xml[key.to_sym]
      when /^[aA-zZ]+__0\d+$/
        if xml_hash[xml_key].nil?
          xml_hash[xml_key] = [nil] 
        end
        xml_hash[xml_key] << { "Content" => xml[key.to_sym] }
      when /^[aA-zZ]+__[aA-zZ]$/
        xml_hash[xml_key][1][xml_subkey] = xml[key.to_sym]
      when /^[aA-zZ]+$/
        xml_hash[xml_key] = [ nil, { "Content" => xml[key.to_sym] }]
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
    xml_attributes = self.attributes.except(:Name,:DeplStateID,:InciStateID,:DefinitionID,
      :CreateTime,:ChangeBy,:ChangeTime,:Class,:ClassID,:ConfigItemID,:CreateBy,:CreateTime,
      :CurDeplState,:CurDeplStateID,:CurDeplStateType,:CurInciState,:CurInciStateID,:CurInciStateType,
      :DeplState,:DeplStateType,:InciState,:InciStateType,:LastVersionID,:Number,:VersionID)
    xml_attributes.each do |key,value|
      updated_attributes = updated_attributes.except(key)
    end
    data = updated_attributes
    params = "Object=ConfigItemObject&Method=VersionAdd&Data=#{data}"
    params = { :object => 'ConfigItemObject', :method => 'VersionAdd', :data => data }
    a = self.class.connect(params)
    new_version_id = a.first
    params2 = "Object=ConfigItemObject&Method=VersionConfigItemIDGet&Data={\"VersionID\":\"#{new_version_id}\"}"
    data2 = { 'VersionID' => new_version_id }
    params2 = { :object => 'ConfigItemObject', :method => 'VersionConfigItemIDGet', :data => data2 }
    b = self.class.connect(params2)
    config_item = self.class.find(b.first)
    attributes = config_item.attributes
    attributes.each do |key,value|
      instance_variable_set "@#{key.to_s}", value
    end
    config_item
  end
  
  def self.from_otrs_xml(xml)
    xml = xml.first[1].flatten[1][1].except("TagKey")
    data = {}
    xml.each do |key,value|
      xml[key].delete(xml[key][0])
      count = xml[key].count
      if count == 1
        data[key] = value[count - 1]["Content"]
        count2 = value[count -1].except("Content","TagKey").count
        if count2 >= 1
          value[count - 1].except("Content","TagKey").each do |key2,value2|
            value2.delete(value2[0])
            data["#{key}__#{key2}"] = value2[0]["Content"]
          end
        end
      else
        while count != 0
          data["#{key}__0#{count - 1}"] = value[count - 1]["Content"]
          count3 = value[count - 1].except("TagKey").count
          if count3 > 1
            value[count - 1].except("Content","TagKey").each do |key3,value3|
              value3.delete(value3[0])
              count4 = value3.count
              if count4 > 1
                while count4 != 0
                  unless value3[count4 - 1]["Content"].nil?
                    data["#{key}__0#{count - 1}__#{key3}__0#{count4 - 1}"] = value3[count4 - 1]["Content"]
                  end
                  count4 = count4 - 1
                end
                
              else
                data["#{key}__0#{count - 1}__#{key3}"] = value3[0]["Content"]
              end
            end
          end
          count = count - 1
        end
      end
    end
    data
  end
  
  def self.find(id)
    data = { 'ConfigItemID' => id }
    params = { :object => 'ConfigItemObject', :method => 'ConfigItemGet', :data => data }
    a = connect(params).first
    class_id = a["ClassID"]
    version_id = a["LastVersionID"]
    data2 = { 'ClassID' => class_id, 'VersionID' => version_id }
    params2 = { :object => 'ConfigItemObject', :method => '_XMLVersionGet', :data => data2 }
    b = connect(params2)
    b = self.from_otrs_xml(b)
    data3 = { 'ConfigItemID' => id, 'XMLDataGet' => 0 }
    params3 = { :object => 'ConfigItemObject', :method => 'VersionGet', :data => data3 }
    c = connect(params3).first
    self.new(a.merge(c).merge(b))
  end
  
end