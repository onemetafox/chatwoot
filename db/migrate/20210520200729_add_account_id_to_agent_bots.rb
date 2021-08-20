class AddAccountIdToAgentBots < ActiveRecord::Migration[6.0]
  def change
    add_column :accounts, :user_id, :integer
    add_reference :accounts, :users, uuid: true
  end
end
