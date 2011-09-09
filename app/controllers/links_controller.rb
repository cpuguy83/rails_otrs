class LinksController < ApplicationController
  before_filter :find_link, :only => [:show, :edit, :update, :destroy]

  # GET /links
  # GET /links.xml
  def index
    @links = OTRS::Link.where(params[:q])

    respond_to do |wants|
      wants.html # index.html.erb
      wants.xml  { render :xml => @links }
      wants.json { render :json => @links }
    end
  end

  # GET /links/1
  # GET /links/1.xml
  def show
    respond_to do |wants|
      wants.html # show.html.erb
      wants.xml  { render :xml => @link }
      wants.json { render :json => @link }
    end
  end

  # GET /links/new
  # GET /links/new.xml
  def new
    @link = OTRS::Link.new

    respond_to do |wants|
      wants.html # new.html.erb
      wants.xml  { render :xml => @link }
      wants.json { render :json => @link }
    end
  end

  # GET /links/1/edit
  def edit
  end

  # POST /links
  # POST /links.xml
  def create
    @link = OTRS::Link.new(params[:link])

    respond_to do |wants|
      if @link.save
        flash[:notice] = 'Link was successfully created.'
        wants.html { redirect_to(@link) }
        wants.xml  { render :xml => @link, :status => :created, :location => @link }
        wants.json { render :json => @link, :status => :created, :location => @link  }
      else
        wants.html { render :action => "new" }
        wants.xml  { render :xml => @link.errors, :status => :unprocessable_entity }
        wants.json { render :json => @link.errors.full_messages, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /links/1
  # PUT /links/1.xml
  def update
    respond_to do |wants|
      if @link.update_attributes(params[:link])
        flash[:notice] = 'Link was successfully updated.'
        wants.html { redirect_to(@link) }
        wants.xml  { head :ok }
        wants.json { head :ok }
      else
        wants.html { render :action => "edit" }
        wants.xml  { render :xml => @link.errors, :status => :unprocessable_entity }
        wants.json { render :json => @link.errors.full_messags, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /links/1
  # DELETE /links/1.xml
  def destroy
    @link.destroy

    respond_to do |wants|
      wants.html { redirect_to(links_url) }
      wants.xml  { head :ok }
      wants.json { head :ok }
    end
  end

  private
    def find_link
      @link = OTRS::Link.find(params[:id])
    end

end
