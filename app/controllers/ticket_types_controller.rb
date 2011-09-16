class TicketTypesController < ApplicationController
  def index
    @types = OTRS::Ticket::Type.all
    respond_to do |wants|
      wants.json { render :json => @types }
    end
  end

end