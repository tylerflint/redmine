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
    @projects = Project.visible.find(:all, :order => 'id, parent_id') 
    @tree = create_project_tree
    project_ids = get_project_ids.join ","
    @buckets = IssueBucket.all()
    @ordered_issues = Issue.find(:all, :conditions => "`order` > 0 AND `project_id` IN (#{project_ids}) AND status_id NOT IN (3,5,6)", :include => [:issue_bucket, :project], :order => "`order`")
    @unordered_issues = Issue.find(:all, :conditions => "(`order` = 0 OR `order` IS null) AND `project_id` IN (#{project_ids}) AND status_id NOT IN (3,5,6)", :include => [:issue_bucket, :project])
    #    @unbucketed_issues = Issue.find(:all, :conditions => "issue_bucket_id is null or issue_bucket_id = 0")
    respond_to do |format|
     format.html { render :template => 'issue_order/index.html.erb', :layout => !request.xhr? }
    end
  end
  
  def global
    @projects = Project.visible.find(:all, :order => 'id, parent_id') 
    @tree = create_project_tree
    project_ids = get_member_project_ids.join ","
    @buckets = IssueBucket.all()
    @ordered_issues = Issue.find(:all, :conditions => "`order` > 0 AND `project_id` IN (#{project_ids}) AND status_id NOT IN (3,5,6)", :include => [:issue_bucket, :project], :order => "`order`")
    @unordered_issues = Issue.find(:all, :conditions => "(`order` = 0 OR `order` IS null) AND `project_id` IN (#{project_ids}) AND status_id NOT IN (3,5,6)", :include => [:issue_bucket, :project])
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
      Issue.update_all(['`order`=?', index+1], ['id=?', id])
    end
    if (params[:unordered_issues])
      params[:unordered_issues].split(",").each do |id|
        Issue.update_all(['`order`=?', 0], ['id=?', id])
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
  
  def get_project_ids(project=nil)
    project ||= @project
    ids = [project.id]
    project.children.each do |child|
      ids << get_project_ids(child)
    end
    ids
  end
  
  def get_member_project_ids
    project_ids = []
    @projects.each do |p|
      project_ids << p.id
    end
    project_ids
  end
  
  def create_project_tree
    tree = []
    @projects.each do |p|
      name = p.name
      name = tree[p.parent_id] + " :: " + name if (p.parent_id)
      tree[p.id] = name
    end
    tree
  end

end
