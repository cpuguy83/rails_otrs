class ConfigItemsController < ApplicationController
  before_filter :find_ConfigItem, :only => [:show, :edit, :update, :destroy]

  # GET /oTRS::ConfigItems
  # GET /oTRS::ConfigItems.xml
  def index
    @config_items = OTRS::ConfigItem.where(params[:q])

    respond_to do |wants|
      wants.html # index.html.erb
      wants.xml  { render :xml => @config_items }
      wants.json { render :json => @config_items }
    end
  end

  # GET /oTRS::ConfigItems/1
  # GET /oTRS::ConfigItems/1.xml
  def show
    respond_to do |wants|
      wants.html # show.html.erb
      wants.xml  { render :xml => @config_item }
      wants.json { render :json => @config_item }
    end
  end

  # GET /oTRS::ConfigItems/new
  # GET /oTRS::ConfigItems/new.xml
  def new
    @config_item = OTRS::ConfigItem.new

    respond_to do |wants|
      wants.html # new.html.erb
      wants.xml  { render :xml => @config_item }
      wants.json { render :json => @config_item }
    end
  end

  # GET /oTRS::ConfigItems/1/edit
  def edit
  end

  # POST /oTRS::ConfigItems
  # POST /oTRS::ConfigItems.xml
  def create
    @config_item = OTRS::ConfigItem.new(params[:config_item])

    respond_to do |wants|
      if @config_item.save
        flash[:notice] = 'ConfigItem was successfully created.'
        wants.html { redirect_to(@config_item) }
        wants.xml  { render :xml => @config_item, :status => :created, :location => @config_item }
        wants.json { render :json => @config_item, :status => :created, :location => @config_item }
      else
        wants.html { render :action => "new" }
        wants.xml  { render :xml => @config_item.errors, :status => :unprocessable_entity }
        wants.json { render :json => @config_item.errors.full_messages, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /oTRS::ConfigItems/1
  # PUT /oTRS::ConfigItems/1.xml
  def update
    respond_to do |wants|
      if @config_item.update_attributes(params[:config_item])
        flash[:notice] = 'ConfigItem was successfully updated.'
        wants.html { redirect_to(@config_item) }
        wants.xml  { head :ok }
        wants.json  { head :ok }
      else
        wants.html { render :action => "edit" }
        wants.xml  { render :xml => @config_item.errors, :status => :unprocessable_entity }
        wants.json  { render :json => @config_item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /oTRS::ConfigItems/1
  # DELETE /oTRS::ConfigItems/1.xml
  def destroy
    @config_item.destroy

    respond_to do |wants|
      wants.html { redirect_to(config_items_url) }
      wants.xml  { head :ok }
      wants.json  { head :ok }
    end
  end

  private
    def find_ConfigItem
      @config_item = OTRS::ConfigItem.find(params[:id])
    end

end
