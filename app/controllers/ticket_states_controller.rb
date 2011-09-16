class TicketStatesController < ApplicationController
  def index
    @types = OTRS::Ticket::State.all
    respond_to do |wants|
      wants.json { render :json => @types }
    end
  end

end