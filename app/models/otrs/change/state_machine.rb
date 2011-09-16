class OTRS::Change::StateMachine < OTRS::Change
  @@class = 'ITSM::ChangeManagement::Change::State'
  
  def self.set_accessor(key)
    attr_accessor key.to_sym
  end
  
  def persisted?
    false
  end
  
  def attributes
    attributes = {}
    self.instance_variables.each do |v|
      attributes[v.to_s.gsub('@','').to_sym] = self.instance_variable_get(v)
    end
    attributes
  end
  
  def initialize(attributes = {})
    attributes.each do |name, value|
      self.class.set_accessor(name.to_s.underscore)
      send("#{name.to_s.underscore.to_sym}=", value)
    end
  end
  
  def self.all
    params = "Object=StateMachineObject&Method=StateList&Data={\"Class\":\"#{@@class}\",\"UserID\":\"1\"}"
    a = connect(params).flatten
    b = []
    a.each do |c|
      tmp = {}
      c.each do |key,value|
        case key
        when "Key" then tmp[:id] = value
        when "Value" then tmp[:name] = value
        end
      end
      c = tmp
      b << new(c)
    end
    b
  end
  
  def next_state
    params = "Object=StateMachineObject&Method=StateTransitionGet&Data={\"StateID\":\"#{id}\",\"Class\":\"#{@@class}\"}"
    a = connect(params).flatten
    b = []
    a.each do |c|
      b << self.class.find(c)
    end
    b
  end
end