class ArticlesController < ApplicationController

  # GET /articles
  # GET /articles.xml
  def index
    @articles = OTRS::Ticket::Article.where(params[:q])

    respond_to do |wants|
      wants.html # index.html.erb
      wants.xml  { render :xml => @articles }
      wants.json  { render :json => @articles }
    end
  end

  # GET /articles/1
  # GET /articles/1.xml
  def show
    respond_to do |wants|
      wants.html # show.html.erb
      wants.xml  { render :xml => @article }
      wants.json { render :json => @article }
    end
  end

  # GET /articles/new
  # GET /articles/new.xml
  def new
    @article = OTRS::Ticket::Article.new

    respond_to do |wants|
      wants.html # new.html.erb
      wants.xml  { render :xml => @article }
      wants.json { render :json => @article }
    end
  end

  # GET /articles/1/edit
  def edit
  end

  # POST /articles
  # POST /articles.xml
  def create
    @article = OTRS::Ticket::Article.new(params[:article])

    respond_to do |wants|
      if @article.save
        flash[:notice] = 'Article was successfully created.'
        wants.html { redirect_to(@article) }
        wants.xml  { render :xml => @article, :status => :created, :location => @article }
        wants.json { render :json => @article, :status => :created, :locaton => @article }
      else
        wants.html { render :action => "new" }
        wants.xml  { render :xml => @article.errors, :status => :unprocessable_entity }
        wants.json  { render :json => @article.errors.full_messages, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /articles/1
  # PUT /articles/1.xml
  def update
    respond_to do |wants|
      if @article.update_attributes(params[:article])
        flash[:notice] = 'Article was successfully updated.'
        wants.html { redirect_to(@article) }
        wants.xml  { head :ok }
      else
        wants.html { render :action => "edit" }
        wants.xml  { render :xml => @article.errors, :status => :unprocessable_entity }
        wants.json  { render :json => @article.errors.full_messages, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /articles/1
  # DELETE /articles/1.xml
  def destroy
    @article.destroy

    respond_to do |wants|
      wants.html { redirect_to(articles_url) }
      wants.xml  { head :ok }
    end
  end

end
