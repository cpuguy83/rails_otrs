class OTRS::Ticket < OTRS

  def self.set_accessors(key)
    attr_accessor key.to_sym
  end
  
  def persisted?
    false
  end
  
  def initialize(attributes = {})
    attributes.each do |name, value|
      OTRS::Ticket.set_accessors(name.to_s.underscore)
      send("#{name.to_s.underscore.to_sym}=", value)
    end
  end
  
  def self.ticket_number_lookup(ticket_id)
    params = "Object=TicketObject&Method=TicketNumberLookup&Data={\"TicketID\":\"#{ticket_id}\",\"UserID\":\"1\"}"
    connect(params).first
  end
  
  def attributes
    @attributes
  end
  
  def save
    create(self.attributes)
  end
  
  def create(attributes={})
    attributes = attributes.to_json
    state_id = connect("Object=StateObject&Method=StateLookup&Data={\"State\":\"#{@state}\"}").first
    a = connect("Object=TicketObject&Method=TicketCreate&Data={\"Title\":\"#{@title}\",\"Type\":\"#{@type}\",\"StateID\":\"#{@state_id}\",\"Queue\":\"#{@queue}\",\"Lock\":\"lock\",\"Priority\":\"3 normal\",\"State\":\"new\",\"CustomerID\":\"#{@email}\",\"CustomerUser\":\"#{@email}\",\"OwnerID\":\"1\",\"UserID\":\"1\"}")
    @ticket_id = a.first
    b = OTRS::Ticket::Article.create(@ticket_id, body, email, title)
    @ticket = self.class.find(@ticket_id)
  end
  
  def self.destroy(id)
    find(id)
    params = "Object=TicketObject&Method=TicketDelete&Data={\"TicketID\":\"#{id}\",\"UserID\":\"1\"}"
    connect(params)
    "Ticket ID: #{id} deleted"
  end
  
  def self.find(id)
    params = "Object=TicketObject&Method=TicketGet&Data={\"TicketID\":\"#{id}\",\"UserID\":\"1\"}"
    a = Hash[*connect(params)]
    if a.empty? == false
      self.new(a.symbolize_keys)
    else
      raise "ERROR::NoSuchID #{id}"
    end
  end
  
  
  def self.where(attributes)
    #Available fields are:
    #Queues (comma spearated), TicketNumber, Title, Types, States, StateType, Priorities, Services, SLAs, Locks, OwnerIDs, ResponsibleIDs
    #WatchUserIDs, CustomerID, CustomerUserLogin, CreatedUserID, CreatedTypes, CreatedPriorities, CreatedStates, CreatedQueues, TicketFreeKey1(2), TicketFreeText1(2)
    #TicketFreeTime1NewerDate, TicketFreTime1OlderDate, TicketFlag, From, To, CC, Subject, Body
    
    terms = attributes.to_json
    params = "Object=TicketObject&Method=TicketSearch&Data=#{terms}"
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
  
end