class CreateImageThreads < ActiveRecord::Migration
  def change
    create_table :image_threads do |t|
      t.string :title
      t.integer :number

      t.timestamps
    end
  end
end
