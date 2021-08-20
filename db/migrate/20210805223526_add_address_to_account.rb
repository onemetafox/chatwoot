class AddAddressToAccount < ActiveRecord::Migration[6.1]
  def change
    add_column :accounts, :billing_address, :string
    add_column :accounts, :shipping_address, :string
    add_column :accounts, :uuid, :string
    add_column :accounts, :email, :string
  end
end
