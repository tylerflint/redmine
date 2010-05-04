class IssueOrderController < ApplicationController
  layout 'base'
  
  before_filter :find_project, :only => :index
  
  helper :journals
  helper :projects
  include ProjectsHelper   
  helper :custom_fields
  include CustomFieldsHelper
  helper :watchers
  include WatchersHelper
  helper :attachments
  include AttachmentsHelper
  helper :queries
  include QueriesHelper
  helper :sort
  include SortHelper
  helper :timelog
  include Redmine::Export::PDF
  
  def index
    @buckets = IssueBucket.all()
    @ordered_issues = Issue.find(:all, :conditions => "`order` > 0", :include => :issue_bucket, :order => "`order`")
    @unordered_issues = Issue.find(:all, :conditions => "(`order` = 0 or `order` is null)", :include => :issue_bucket)
#    @unbucketed_issues = Issue.find(:all, :conditions => "issue_bucket_id is null or issue_bucket_id = 0")
    respond_to do |format|
      format.html { render :template => 'issue_order/index.html.erb', :layout => !request.xhr? }
    end
  end

  def add_bucket
    @bucket = IssueBucket.new(params[:issue_bucket])
    @bucket.save

    render :js => "window.location.reload()"
    
    # render :update do |page|
    #   page['addbuckets'].hide
    #   page.insert_html :bottom, 'buckets', '<input type="checkbox" id="bucket[' + @bucket.id.to_s + ']" checked>' + @bucket.name + '</input>'
    #   page['name:issue_bucket[name]'].clear
    # end
  end

  def remove_bucket
    @bucket = IssueBucket.find(params[:id])
    Issue.update_all(['issue_bucket_id=?', 0], ['issue_bucket_id=?', params[:id]])
    @bucket.destroy
    
   render :js => "window.location.reload()"
   
  end

  def edit_bucket
  end

  def save
    if params[:issue]
      @issue = Issue.find(params[:issue][:id])
      @issue.update_attributes(params[:issue])
      @issue.save
    end
    render :update do |page|
      page['issue-saved-' + @issue.id.to_s].innerHTML = "Saved"
    end
  end
  
  def save_orders
    params[:issues].split(",").each_with_index do |id, index|
      Issue.update_all(['[order]=?', index+1], ['id=?', id])
    end
    if (params[:unordered_issues])
      params[:unordered_issues].split(",").each do |id|
        Issue.update_all(['[order]=?', 0], ['id=?', id])
      end
    end
    render :update do |page|
      page['success'].innerHTML = ""
    end
  end

private
  def find_project
    project_id = (params[:issue] && params[:issue][:project_id]) || params[:project_id]
    @project = Project.find(project_id)
  rescue ActiveRecord::RecordNotFound
    render_404
  end

end
