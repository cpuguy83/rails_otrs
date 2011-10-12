class OTRS::Change < OTRS
  
  def self.set_accessor(key)
    attr_accessor key.to_sym
  end
  
  def persisted?
    false
  end
  
  def initialize(attributes = {})
    attributes.each do |name, value|
      self.class.set_accessor(name.to_s.underscore)
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
    self.create(self.attributes)
  end
  
  def create(attributes)
    tmp = {}
    attributes.each do |key,value|
       tmp[key.to_s.camelize.to_sym] = value
    end
    attributes = tmp
    attributes[:UserID] = '1'
    data = attributes
    params = { :object => 'ChangeObject', :method => 'ChangeAdd', :data => data }
    a = connect(params)
    id = a.first
    a = self.class.find(id)
    attributes = a.attributes
    attributes.each do |key,value|
      instance_variable_set "@#{key.to_s}", value
    end
  end
    
  def self.find(id)
    data = { 'ChangeID' => id, 'UserID' => 1 }
    params = { :object => 'ChangeObject', :method => 'ChangeGet', :data => data }
    a = connect(params)
    a = Hash[*a]
    self.new(a.symbolize_keys)
  end
  
  def self.where(attributes)
    tmp = {}
    attributes.each do |key,value|
      tmp[key.to_s.camelize] = value      #Copies ruby style keys to camel case for OTRS
    end
    data = tmp
    params = { :object => 'ChangeObject', :method => 'ChangeSearch', :data => data }
    a = connect(params).flatten
    b = []
    a.each do |c|
      b << find(c)
    end
    b
  end
  
  def update_attributes(attributes)
    tmp = {}
    attributes.each do |key,value|
      tmp[key.to_s.camelize] = value      #Copies ruby style keys to camel case for OTRS
    end
    tmp['ChangeID'] = @change_id
    data = tmp
    params = { :object => 'ChangeObject', :method => 'ChangeUpdate', :data => data }
    a = connect(params)
    if a.first.nil?
      nil
    else
      return self
    end
  end
  
  def destroy
    id = @change_id
    if self.class.find(id)
      data = { 'ChangeID' => id, 'UserID' => 1 }
      params = { :object => 'ChangeObject', :method => 'ChangeDelete', :data => data }
      connect(params)
      "ChangeID #{id} deleted"
    else
      raise "NoSuchChangeID #{id}"
    end
  end
  
end