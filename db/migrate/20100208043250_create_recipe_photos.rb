class CreateRecipePhotos < ActiveRecord::Migration
  def self.up
    create_table :recipe_photos do |t|
      t.integer :recipe_id
      t.string  :photo_file_name
      t.string  :photo_content_type
      t.integer :photo_file_size
      t.timestamps
    end
  end

  def self.down
    drop_table :recipe_photos
  end
end
