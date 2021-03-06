class NewswiresController < ApplicationController
  before_filter :set_current_tab
  before_filter :set_ad_layout, :only => [:index]
  before_filter :login_required, :only => [:quick_post]
  before_filter :load_top_stories, :only => [:index]

  after_filter :store_location, :only => [:index]

  def index
    @current_sub_tab = 'Browse Wires'
    @page = params[:page].present? ? (params[:page].to_i < 3 ? "page_#{params[:page]}_" : "") : "page_1_"
    @newswires = Newswire.active.unpublished.newest.paginate :page => params[:page], :per_page => 20, :order => "created_at desc"
    @paginate = true
  end

  def feed_index
    @feed = Feed.enabled.active.find(params[:feed_id])    
    @current_sub_tab = 'Browse Wires'
    @page = params[:page].present? ? (params[:page].to_i < 3 ? "page_#{params[:page]}_" : "") : "page_1_"
    @newswires = @feed.newswires.unpublished.paginate :page => params[:page], :per_page => 20, :order => "created_at desc"
    @paginate = true
  end

  def quick_post
    @newswire = Newswire.active.find_by_id(params[:id])
    redirect_to newswire_path and return if @newswire.nil?

    respond_to do |format|
      if @newswire.quick_post(current_user.id)
        success = "Thanks for posting!"
        format.html { flash[:success] = success; redirect_to story_path(@newswire.content) }
        format.json { render :json => { :msg => success }.to_json }
      else
        format.html { flash[:error] = "Could not publish your story. Please try publishing this post."; redirect_to newswires_path }
        format.json { render :json => { :error => "Quick post failed" }.to_json, :status => 409 }
      end
    end
  end

  private

  def set_current_tab
    @current_tab = 'stories'
  end

end
