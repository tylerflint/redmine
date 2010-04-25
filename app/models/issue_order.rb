class IssueOrder < ActiveRecord::Base
  belongs_to :issue_bucket, :class_name => "IssueBucket", :foreign_key => "issue_bucket_id"
  belongs_to :issue, :class_name => "Issue", :foreign_key => "issue_id"
end
