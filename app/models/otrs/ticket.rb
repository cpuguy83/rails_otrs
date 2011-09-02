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
    @otrs_type ||= 'Incident'
    @state ||= 'new'
    @queue ||= 'Service Desk'
    @lock ||= 'unlock'
    @priority ||= '3 normal'
    @user_id ||= '1'
    @owner_id ||= @user_id
    
    # Put validations here because they are not working using the normal validation methods
    if @title == nil then raise 'ERROR:Missing field title' end
    if @body == nil then raise 'ERROR:Missing field body' end
    if @email == nil then raise 'ERROR:Missing field email' end
    
    state_id = connect("Object=StateObject&Method=StateLookup&Data={\"State\":\"#{@state}\"}").first
    params = "Object=TicketObject&Method=TicketCreate&Data={\"Title\":\"#{@title}\",\"Type\":\"#{@otrs_type}\",\"StateID\":\"#{state_id}\",\"Queue\":\"#{@queue}\",\"Lock\":\"#{@lock}\",\"Priority\":\"#{@priority}\",\"CustomerID\":\"#{@email}\",\"CustomerUser\":\"#{@email}\",\"OwnerID\":\"#{@owner_id}\",\"UserID\":\"#{@user_id}\"}"
    a = connect(params)
    ticket_id = a.first
    b = OTRS::Ticket::Article.create(ticket_id, @body, @email, @title)
    @ticket = self.class.find(ticket_id)
  end
  
  def destroy
    id = @ticket_id
    if self.class.find(id)
      params = "Object=TicketObject&Method=TicketDelete&Data={\"TicketID\":\"#{id}\",\"UserID\":\"1\"}"
      connect(params)
      "Ticket ID: #{id} deleted"
    else
      raise 'Error:NoSuchID'
    end
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
    attributes.each do |key,value|
      attributes[key.to_s.camelize.to_sym] = value      #Copies ruby style keys to camel case for OTRS
      attributes.delete(key)                            #Deletes the ruby style key as we don't want this to go to OTRS
    end
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
  
  def where(attributes)
    self.class.where(attributes)
  end
end