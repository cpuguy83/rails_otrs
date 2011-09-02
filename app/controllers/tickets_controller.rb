class TicketsController < ApplicationController
  before_filter :find_ticket, :only => [:show, :edit, :update, :destroy]

  # GET /tickets
  # GET /tickets.xml
  def index
    @tickets = OTRS::Ticket.where(params[:q])

    respond_to do |wants|
      wants.html # index.html.erb
      wants.xml  { render :xml => @tickets }
      wants.json { render :json => @tickets }
    end
  end

  # GET /tickets/1
  # GET /tickets/1.xml
  def show
    respond_to do |wants|
      wants.html # show.html.erb
      wants.xml  { render :xml => @ticket }
      wants.json { render :json => @ticket }
    end
  end

  # GET /tickets/new
  # GET /tickets/new.xml
  def new
    @ticket = OTRS::Ticket.new

    respond_to do |wants|
      wants.html # new.html.erb
      wants.xml  { render :xml => @ticket }
      wants.json { render :json => @ticket }
    end
  end

  # GET /tickets/1/edit
  def edit
  end

  # POST /tickets
  # POST /tickets.xml
  def create
    @ticket = OTRS::Ticket.new(params[:ticket])

    respond_to do |wants|
      if @ticket.save
        flash[:notice] = 'Ticket was successfully created.'
        wants.html { redirect_to(@ticket) }
        wants.xml  { render :xml => @ticket, :status => :created, :location => @ticket }
        wants.json { render :json => @ticket, :status => :created, :location => @ticket }
      else
        wants.html { render :action => "new" }
        wants.xml  { render :xml => @ticket.errors, :status => :unprocessable_entity }
        wants.json { render :json => @ticket.errors.full_messages, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /tickets/1
  # PUT /tickets/1.xml
  def update
    respond_to do |wants|
      if @ticket.update_attributes(params[:ticket])
        flash[:notice] = 'Ticket was successfully updated.'
        wants.html { redirect_to(@ticket) }
        wants.xml  { head :ok }
        wants.json { head :ok }
      else
        wants.html { render :action => "edit" }
        wants.xml  { render :xml => @ticket.errors, :status => :unprocessable_entity }
        wants.json { render :json => @ticket.errors.full_messages, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /tickets/1
  # DELETE /tickets/1.xml
  def destroy
    @ticket.destroy
    respond_to do |wants|
      wants.html { redirect_to(tickets_url) }
      wants.xml  { head :ok }
      wants.json { head :ok }
    end
  end

  private
    def find_ticket
      @ticket = OTRS::Ticket.find(params[:id])
    end

end
