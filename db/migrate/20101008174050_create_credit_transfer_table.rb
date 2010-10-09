class CreateCreditTransferTable < ActiveRecord::Migration
  def self.up
    create_table :credit_transfers do |t|
      t.integer :sender_id
      t.integer :recipient_id
      t.integer :project_id
      t.float   :amount
      t.string  :note
      t.datetime  :created_at
      t.datetime  :updated_at
    end
  end

  def self.down
    drop_table :credit_transfers
  end
end
