class AddBillingInfoToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :b_first_name, :string
    add_column :users, :b_last_name, :string
    add_column :users, :b_address1, :string
    add_column :users, :b_address2, :string
    add_column :users, :b_city, :string
    add_column :users, :b_state, :string
    add_column :users, :b_zip, :string
    add_column :users, :b_country, :string
    add_column :users, :b_phone, :string
    add_column :users, :b_ip_address, :string
    add_column :users, :b_cc_last_four, :string
    add_column :users, :b_cc_type, :string
    add_column :users, :b_cc_month, :integer
    add_column :users, :b_cc_year, :integer
  end

  def self.down
    remove_column :users, :b_first_name
    remove_column :users, :b_last_name
    remove_column :users, :b_address1
    remove_column :users, :b_address2
    remove_column :users, :b_city
    remove_column :users, :b_state
    remove_column :users, :b_zip
    remove_column :users, :b_country
    remove_column :users, :b_phone
    remove_column :users, :b_ip_address
    remove_column :users, :b_cc_last_four
    remove_column :users, :b_cc_type
    remove_column :users, :b_cc_month
    remove_column :users, :b_cc_year
  end
end
