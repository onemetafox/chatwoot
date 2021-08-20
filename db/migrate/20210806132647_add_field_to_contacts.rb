class AddFieldToContacts < ActiveRecord::Migration[6.1]
  def change
    add_column :contacts, :alt_email, :string
    add_column :contacts, :address, :string
    add_column :contacts, :deleted_at, :datetime
  end
end
