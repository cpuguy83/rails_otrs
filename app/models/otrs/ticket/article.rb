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
  
  def self.create(ticket_id, body, email, title)
    params = "Object=TicketObject&Method=ArticleCreate&Data={\"TicketID\":\"#{ticket_id}\",\"UserID\":\"1\",\"ArticleType\":\"email-internal\",\"SenderType\":\"agent\",\"From\":\"#{email}\",\"Subject\":\"#{title}\",\"Body\":\"#{body}\",\"HistoryType\":\"AddNote\",\"HistoryComment\":\" \",\"ContentType\":\"text/plain\"}"
    connect(params)
  end
  
  def self.find(id)
    params = "Object=TicketObject&Method=ArticleGet&Data={\"ArticleID\":\"#{id}\",\"UserID\":\"1\"}"
    a = connect(params)
    a = Hash[*a].symbolize_keys
    self.new(a)
  end
  
  def self.where(ticket_id)
    params="Object=TicketObject&Method=ArticleIndex&Data={\"TicketID\":\"#{ticket_id}\"}"
    a = connect(params)
    b = []
    a.each do |c|
      b << find(c)
    end
    b
  end

end