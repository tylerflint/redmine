class CreateIssueBuckets < ActiveRecord::Migration
  def self.up
    create_table :issue_buckets do |t|
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :issue_buckets
  end
end
