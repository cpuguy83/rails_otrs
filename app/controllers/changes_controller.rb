class ChangesController < ApplicationController
  before_filter :find_change, :only => [:show, :edit, :update, :destroy]

  # GET /changes
  # GET /changes.xml
  def index
    @changes = OTRS::Change.where(params[:q])

    respond_to do |wants|
      wants.html # index.html.erb
      wants.json  { render :json => @changes }
    end
  end

  # GET /changes/1
  # GET /changes/1.xml
  def show
    respond_to do |wants|
      wants.html # show.html.erb
      wants.json  { render :json => @change }
    end
  end

  # GET /changes/new
  # GET /changes/new.xml
  def new
    @change = OTRS::Change.new

    respond_to do |wants|
      wants.html # new.html.erb
      wants.json  { render :json => @change }
    end
  end

  # GET /changes/1/edit
  def edit
  end

  # POST /changes
  # POST /changes.xml
  def create
    @change = OTRS::Change.new(params[:change])

    respond_to do |wants|
      if @change.save
        flash[:notice] = 'Change was successfully created.'
        wants.html { redirect_to(@change) }
        wants.json  { render :json => @change, :status => :created, :location => @change }
      else
        wants.html { render :action => "new" }
        wants.json  { render :json => @change.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /changes/1
  # PUT /changes/1.xml
  def update
    respond_to do |wants|
      if @change.update_attributes(params[:change])
        flash[:notice] = 'Change was successfully updated.'
        wants.html { redirect_to(@change) }
        wants.json  { head :ok }
      else
        wants.html { render :action => "edit" }
        wants.json  { render :json => @change.errors.full_messages, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /changes/1
  # DELETE /changes/1.xml
  def destroy
    @change.destroy

    respond_to do |wants|
      wants.html { redirect_to(changes_url) }
      wants.json  { head :ok }
    end
  end

  private
    def find_change
      @change = OTRS::Change.find(params[:id])
    end

end
