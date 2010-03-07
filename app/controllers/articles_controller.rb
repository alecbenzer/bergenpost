require 'date'
require 'digest/sha1'

class ArticlesController < ApplicationController
  before_filter :authenticate, :except => [:show, :category, :recent, :popular, :feed]

  def index
    @articles = Article.find(:all)

    respond_to do |format|
      format.html
      format.xml { render :xml => @articles }
      format.atom
    end
  end
  
  def feed
    @articles = Article.find(:all, :order => 'created_at DESC', :limit => 10)
  
    respond_to do |format|
      format.atom
    end
  end
  
  def category
    @category = Category.find_by_name(params[:category])
    @articles = Article.find_all_by_category_id(@category[:id])
    respond_to do |format|
      format.html 
      format.xml  { render :xml => @articles }
    end
  end

  def recent
    @articles = Article.find(:all, :order => 'created_at DESC')

    respond_to do |format|
      format.html 
      format.xml  { render :xml => @articles }
    end
  end

  def popular
    @articles = Article.find(:all).sort { |a,b| b.popularity <=> a.popularity }

    respond_to do |format|
      format.html 
      format.xml  { render :xml => @articles }
    end
  end

  def show
    @months = {1 => 'January', 2 => 'February', 3 => 'March', 4 => 'April', 5 => 'May', 6 => 'June', 7 => 'July', 8 => 'August', 9 => 'September', 10 => 'October', 11 => 'November', 12 => 'December' }
    
    @years = []
    Article.find(:all).each do |a|
      @years << a.created_at.year unless @years.index a.created_at.year
    end
  
    @article = Article.find(params[:id])
    begin
      @prev = Article.find((params[:id].to_i-1).to_s)
    rescue
      @prev = @article
    end
    begin
      @next = Article.find((params[:id].to_i+1).to_s)
    rescue
      @next = @article
    end
    @article.views += 1
    @article.save

    unless params[:comment].nil? or params[:comment].empty?
      @comment = @article.comments.build(params[:comment])
      @comment.save
    end

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @article }
    end
  end

  def new
    @article = Article.new
    @authors = Author.find(:all)
    @categories = Category.find(:all)

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @article }
    end
  end

  # GET /articles/1/edit
  def edit
    @article = Article.find(params[:id])
    @authors = Author.find(:all)
    @categories = Category.find(:all)
  end

  def create
    @article = Article.new(params[:article])
    @article.author = Author.find(params[:author][:id])
    @article.category = Category.find(params[:category][:id])
    @article.views = 0

    respond_to do |format|
      if @article.save
        flash[:notice] = 'Article was successfully created.'
        format.html { redirect_to @article }
        format.xml  { render :xml => @article, :status => :created, :location => @article }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @article.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @article = Article.find(params[:id])

    respond_to do |format|
      if @article.update_attributes(params[:article])
        flash[:notice] = 'Article was successfully updated.'
        format.html { redirect_to(@article) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @article.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @article = Article.find(params[:id])
    @article.destroy

    respond_to do |format|
      format.html { redirect_to(articles_url) }
      format.xml  { head :ok }
    end
  end
  
  private
  
  def authenticate  
    authenticate_or_request_with_http_basic do |name, password|
      name == "admin" && Digest::SHA1.hexdigest(password) == "8e11fefdde5ec716ad061d48b24f18fb44e6ab17"
    end
  end
  
end
