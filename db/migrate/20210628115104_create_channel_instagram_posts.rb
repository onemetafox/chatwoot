class CreateChannelInstagramPosts < ActiveRecord::Migration[6.0]
  def change
    create_table :channel_instagram_posts do |t|
      t.string :page_id, null: false
      t.string :user_access_token, null: false
      t.string :page_access_token, null: false
      t.references :accounts, null: false
      t.string :post_link
      t.timestamps
    end
  end
end
