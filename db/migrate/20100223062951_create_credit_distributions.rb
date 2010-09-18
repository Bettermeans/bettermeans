class CreateCreditDistributions < ActiveRecord::Migration
  def self.up
    create_table :credit_distributions do |t|
      t.integer :user_id
      t.integer :project_id
      t.integer :retro_id
      t.float :amount

      t.datetime :created_at
      t.datetime :updated_at
    end
  end

  def self.down
    drop_table :credit_distributions
  end
end
