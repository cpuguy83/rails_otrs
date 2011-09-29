class ServicesController < ApplicationController
  before_filter :find_service, :only => [:show, :edit, :update, :destroy]

  # GET /services
  # GET /services.xml
  def index
    @services = OTRS::Service.where(params[:q])

    respond_to do |wants|
      wants.html # index.html.erb
      wants.json  { render :json => @services }
    end
  end

  # GET /services/1
  # GET /services/1.xml
  def show
    respond_to do |wants|
      wants.html # show.html.erb
      wants.json  { render :json => @service }
    end
  end

  # GET /services/new
  # GET /services/new.xml
  def new
    @service = OTRS::Service.new

    respond_to do |wants|
      wants.html # new.html.erb
      wants.json  { render :json => @service }
    end
  end

  # GET /services/1/edit
  def edit
  end

  # POST /services
  # POST /services.xml
  def create
    @service = OTRS::Service.new(params[:service])

    respond_to do |wants|
      if @service.save
        flash[:notice] = 'Service was successfully created.'
        wants.html { redirect_to(@service) }
        wants.json  { render :json => @service, :status => :created, :location => @service }
      else
        wants.html { render :action => "new" }
        wants.json  { render :json => @service.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /services/1
  # PUT /services/1.xml
  def update
    respond_to do |wants|
      if @service.update_attributes(params[:service])
        flash[:notice] = 'Service was successfully updated.'
        wants.html { redirect_to(@service) }
        wants.json  { head :ok }
      else
        wants.html { render :action => "edit" }
        wants.json  { render :json => @service.errors.full_messages, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /services/1
  # DELETE /services/1.xml
  def destroy
    @service.destroy

    respond_to do |wants|
      wants.html { redirect_to(services_url) }
      wants.json  { head :ok }
    end
  end

  private
    def find_service
      @service = OTRS::Service.find(params[:id])
    end

end
