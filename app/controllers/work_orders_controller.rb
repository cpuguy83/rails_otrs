class WorkOrdersController < ApplicationController
  before_filter :find_work_order, :only => [:show, :edit, :update, :destroy]

  # GET /workOrders
  # GET /workOrders.xml
  def index
    @work_orders = OTRS::Change::WorkOrder.where(params[:q])

    respond_to do |wants|
      wants.html # index.html.erb
      wants.json  { render :json => @work_orders }
    end
  end

  # GET /workOrders/1
  # GET /workOrders/1.xml
  def show
    respond_to do |wants|
      wants.html # show.html.erb
      wants.json  { render :json => @work_order }
    end
  end

  # GET /workOrders/new
  # GET /workOrders/new.xml
  def new
    @work_order = OTRS::Change::WorkOrder.new

    respond_to do |wants|
      wants.html # new.html.erb
      wants.json  { render :json => @work_order }
    end
  end

  # GET /workOrders/1/edit
  def edit
  end

  # POST /workOrders
  # POST /workOrders.xml
  def create
    @work_order = OTRS::Change::WorkOrder.new(params[:work_order])

    respond_to do |wants|
      if @work_order.save
        flash[:notice] = 'Work Order was successfully created.'
        wants.html { redirect_to(@work_order) }
        wants.json  { render :json => @work_order, :status => :created, :location => @work_order }
      else
        wants.html { render :action => "new" }
        wants.json  { render :json => @work_order.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /workOrders/1
  # PUT /workOrders/1.xml
  def update
    respond_to do |wants|
      if @work_order.update_attributes(params[:work_order])
        flash[:notice] = 'Work Order was successfully updated.'
        wants.html { redirect_to(@work_order) }
        wants.json  { head :ok }
      else
        wants.html { render :action => "edit" }
        wants.json  { render :json => @work_order.errors.full_messages, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /workOrders/1
  # DELETE /workOrders/1.xml
  def destroy
    @work_order.destroy

    respond_to do |wants|
      wants.html { redirect_to(workOrders_url) }
      wants.json  { head :ok }
    end
  end

  private
    def find_work_order
      @work_order = OTRS::Change::WorkOrder.find(params[:id])
    end

end
