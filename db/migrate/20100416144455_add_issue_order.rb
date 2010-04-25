class AddIssueOrder < ActiveRecord::Migration
  def self.up
    add_column :issues, :order, :integer
    add_column :issues, :issue_bucket_id, :integer
  end

  def self.down
    remove_column :issues, :issue_bucket_id
    remove_column :issues, :order
  end
end
