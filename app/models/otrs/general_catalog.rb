class OTRS::GeneralCatalog < OTRS
  
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
  
  def self.find(id)
    params="Object=GeneralCatalogObject&Method=ItemGet&Data={\"ItemID\":\"#{id}\"}"
    a = connect(params).first.except('Class') # Class field is causing issues
    self.new(a)
  end
  
end