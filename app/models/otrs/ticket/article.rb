class OTRS::Ticket::Article < OTRS::Ticket
  
  def self.set_accessors(key)
    attr_accessor key.to_sym
  end
  
  def initialize(attributes = {})
    attributes.each do |name, value|
      OTRS::Ticket::Article.set_accessors(name.to_s.underscore)
      send("#{name.to_s.underscore.to_sym}=", value)
    end
  end
  
  def self.create(attributes)
    data = { 'TicketID' => attributes[:ticket_id], 'UserID' => 1, 'From' => attributes[:email], 'Subject' => attributes[:title], 'Body', => attributes[:body] }
    data['ArticleType'] ||= 'email-external'
    data['SenderType'] ||= 'agent'
    data['HistoryType'] ||= 'NewTicket'
    data['HistoryComment'] ||= ''
    data['ContentType'] ||= 'text/plain'
    data = data.to_json
    params = { :object => 'TicketObject', :method => 'ArticleCreate', :data => data }
    connect(params)
  end
  
  def self.find(id)
    data = { 'ArticleID' => id, 'UserID' => 1 }
    #params = "Object=TicketObject&Method=ArticleGet&Data={\"ArticleID\":\"#{id}\",\"UserID\":\"1\"}"
    params = { :object => 'TicketObject', :method => 'ArticleGet', :data => data }
    a = connect(params)
    a = Hash[*a].symbolize_keys
    self.new(a)
  end
  
  def self.where(ticket_id)
    data = { 'TicketID' => ticket_id }
    #params="Object=TicketObject&Method=ArticleIndex&Data={\"TicketID\":\"#{ticket_id}\"}"
    params = { :object => 'TicketObject', :method => 'ArticleIndex', :data => data }
    a = connect(params)
    b = []
    a.each do |c|
      b << find(c)
    end
    b
  end

end