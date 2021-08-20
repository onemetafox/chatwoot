class AddFieldToAccounts < ActiveRecord::Migration[6.1]
  def change
    add_column :accounts, :uuid, :string
    add_column :accounts, :email, :string
    add_column :accounts, :deleted_at, :timestamp
    add_column :accounts, :billing_address, :string
    add_column :accounts, :shipping_address, :string
  end
end
