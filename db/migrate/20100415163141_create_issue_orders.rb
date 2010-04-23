class CreateIssueOrders < ActiveRecord::Migration
  def self.up
    create_table :issue_orders do |t|
      t.references :issue
      t.references :issue_bucket
      t.number :order
      t.number :time_estimate
      t.timestamps
    end
  end

  def self.down
    drop_table :issue_orders
  end
end
