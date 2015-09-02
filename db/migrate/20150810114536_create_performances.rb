class CreatePerformances < ActiveRecord::Migration
  def change
    create_table :performances do |t|
      t.string :url
      t.string :name
      t.string :venue
      t.integer :host
      t.integer :medium
      t.integer :performance_type
      t.date :performance_date

      t.timestamps
    end

    create_table :song_performances do |t|
      t.belongs_to :songs, foreign_key: 'SONGID', index: true
      t.belongs_to :performance, index: true
      t.timestamps null: false
    end

  end
end