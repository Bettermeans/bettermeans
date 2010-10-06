class AddDailyDigestTable < ActiveRecord::Migration
  def self.up
    create_table :daily_digests do |t|
      t.integer   :issue_id
      t.integer   :journal_id
      t.string   :mail
      t.datetime  :created_at
      t.datetime  :updated_at
    end
    
    User.all.each do |user|
      user.pref.others.merge!({:daily_digest => true})
      user.pref.save
    end
  end

  def self.down
    drop_table  :plans
  end
end
