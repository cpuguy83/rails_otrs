class OTRS::Ticket::Type < OTRS::Ticket
  
  def self.set_accessor(key)
    attr_accessor key.to_sym
  end
  
  def persisted?
    false
  end
  
  def initialize(attributes = {})
    attributes.each do |name, value|
      OTRS::Ticket.set_accessor(name.to_s.underscore)
      send("#{name.to_s.underscore.to_sym}=", value)
    end
  end
  
  def self.all
    data = { 'UserID' => 1 }
    #params = 'Object=TicketObject&Method=TicketTypeList&Data={"UserID":"1"}'
    params = { :object => 'TicketObject', :method => 'TicketTypeList', :data => data }
    a = connect(params)
    a = Hash[*a]
    b = []
    a.each do |key,value|
      c = {}
      c[key] = value
      b << c
    end
    c = []
    b.each do |d|
      d.each do |key,value|
        tmp = {}
        tmp[:id] = key
        tmp[:name] = value
        c << new(tmp)
      end
    end
    c
  end
  
end