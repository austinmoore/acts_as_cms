class PagesController < ApplicationController

  before_filter :page, :only => [:edit, :update, :destroy]
  
  def index
    @pages = Page.all
  end
  
  def show
    @page = Page.find_by_permalink(params[:id])
    if @page.nil?
      redirect_to new_page_path(:permalink => params[:id])
    end
  end
  
  def new
    @page = Page.new(params)
  end
  
  def create
    @page = Page.new(params[:page])
    if @page.save
      redirect_to @page
    else
      render :action => 'new'
    end
  end
  
  def edit

  end
  
  def update
    if @page.update_attributes(params[:page])
      redirect_to @page
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @page.destroy
    flash[:notice] = "Successfully destroyed page."
    redirect_to pages_url
  end

  private

  def page
    @page = Page.find_by_permalink(params[:id])
    raise ActiveRecord::RecordNotFound, "Page not found" if @page.nil?
  end
end
