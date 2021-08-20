class AddDeleteatToCampains < ActiveRecord::Migration[6.1]
  def change
    add_column :campaigns, :deleted_at, :datetime
  end
end
