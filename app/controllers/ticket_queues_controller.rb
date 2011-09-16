class TicketQueuesController < ApplicationController
  def index
    @queues = OTRS::Ticket::TicketQueue.all
    respond_to do |wants|
      wants.json { render :json => @queues }
    end
  end

end