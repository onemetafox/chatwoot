class CreatePosts < ActiveRecord::Migration[6.0]
  def change
    create_table :posts do |t|
      t.string :title
      t.text :description
      t.string :social_platform
      t.string :post_type
      t.string :action_link
      t.string :images
      t.string :video_url
      t.timestamp :scheduled_at
      t.references :postable, polymorphic: true

      t.timestamps
    end
  end
end
