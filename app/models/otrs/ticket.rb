class OTRS::Ticket < OTRS
  # Validations aren't working
  validates_presence_of :title
  validates_presence_of :body
  validates_presence_of :email

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
  
  def self.ticket_number_lookup(ticket_id)
    data = { 'TicketID' => ticket_id, 'UserID' => 1 }
    #params = "Object=TicketObject&Method=TicketNumberLookup&Data={\"TicketID\":\"#{ticket_id}\",\"UserID\":\"1\"}"
    params = { :object => 'TicketObject', :method => 'TicketNumberLookup', :data => data }
    connect(params).first
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
    attributes[:otrs_type] ||= 'Incident'
    attributes[:state] ||= 'new'
    attributes[:queue] ||= 'Service Desk'
    attributes[:lock] ||= 'unlock'
    attributes[:priority] ||= '3 normal'
    attributes[:user_id] ||= '1'
    attributes[:owner_id] ||= attributes[:user_id]
    tmp = {}
    attributes.each do |key,value|
      if key == :otrs_type
        tmp[:Type] = value
      end
      if key == :user_id
        tmp[:UserID] = value
      end
      if key == :owner_id
        tmp[:OwnerID] = value
      end
      if key == :customer_id
        tmp[:CustomerID] = value
      end
      if key != :user_id or key != :owner_id or key != :customer_id
        tmp[key.to_s.camelize.to_sym] = value
      end

    end
    attributes = tmp
    data = attributes
    params = { :object => 'TicketObject', :method => 'TicketCreate', :data => data }
    a = connect(params)
    ticket_id = a.first
    article = OTRS::Ticket::Article.new(
      :ticket_id => ticket_id, 
      :body => attributes[:Body], 
      :email => attributes[:Email], 
      :title => attributes[:Title])
    if article.save
      ticket = self.class.find(ticket_id)
      attributes = ticket.attributes
      attributes.each do |key,value|
        instance_variable_set "@#{key.to_s}", value
      end
      ticket
    else
      ticket.destroy
      raise 'Could not create ticket'
    end
  end
  
  def destroy
    id = @ticket_id
    if self.class.find(id)
      data = { 'TicketID' => id, 'UserID' => 1 }
      params = { :object => 'TicketObject', :method => 'TicketDelete', :data => data }
      connect(params)
      "Ticket ID: #{id} deleted"
    else
      raise 'Error:NoSuchID'
    end
  end
  
  def self.find(id)
    data = { 'TicketID' => id, 'UserID' => 1 }
    #params = "Object=TicketObject&Method=TicketGet&Data={\"TicketID\":\"#{id}\",\"UserID\":\"1\"}"
    params = { :object => 'TicketObject', :method => 'TicketGet', :data => data }
    a = Hash[*connect(params)]
    if a.empty? == false
      self.new(a.symbolize_keys)
    else
      raise "ERROR::NoSuchID #{id}"
    end
  end
  
  
  def self.where(attributes)
    data = attributes
    params = { :object => 'TicketObject', :method => 'TicketSearch', :data => data }
    a = connect(params)
    b = Hash[*a]          # Converts array to hash where key = TicketID and value = TicketNumber, which is what gets returned by OTRS
    c = []
    b.each do |key,value| # Get just the ID values so we can perform a find on them
      c << key
    end
    results = []
    c.each do |t|
      results << find(t)  #Add find results to array
    end
    results   # Return array of hashes.  Each hash is one ticket record
  end
  
  def where(attributes)
    self.class.where(attributes)
  end
end