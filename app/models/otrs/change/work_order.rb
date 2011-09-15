class OTRS::Change::WorkOrder < OTRS::Change
  
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
    attributes[:ChangeID] = attributes[:ChangeId]
    attributes.delete(:ChangeId)
    data = attributes.to_json
    params = "Object=WorkOrder&Method=WorkOrderAdd&Data=#{data}"
    a = connect(params)
    id = a.first
    a = self.class.find(id)
    attributes = a.attributes
    attributes.each do |key,value|
      instance_variable_set "@#{key.to_s}", value
    end
  end
  
  def self.find(id)
    params = "Object=WorkOrder&Method=WorkOrderGet&Data={\"WorkOrderID\":\"#{id}\",\"UserID\":\"1\"}"
    a = connect(params)
    a = Hash[*a]
    self.new(a.symbolize_keys)
  end
  
  def destroy
    id = @change_id
    if self.class.find(id)
      params = "Object=WorkOrder&Method=WorkOrderDelete&Data={\"ChangeID\":\"#{id}\",\"UserID\":\"1\"}"
      connect(params)
      "WorkOrderID #{id} deleted"
    else
      raise "NoSuchWorkOrderID #{id}"
    end
  end
  
end