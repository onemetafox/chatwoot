class AddAddressToContact < ActiveRecord::Migration[6.1]
  def change
    add_column :contacts, :address, :string
  end
end
