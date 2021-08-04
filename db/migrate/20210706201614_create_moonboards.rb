class CreateMoonboards < ActiveRecord::Migration[6.1]
  def change
    create_table :moonboards do |t|
      t.string :title
      t.timestamps
      t.references :account, null: false, foreign_key: true
    end

    create_table :moonboard_items do |t|
      t.string :text
      t.integer :position
      t.references :moonboard, null: false, foreign_key: true
      t.timestamps
    end
  end
end
