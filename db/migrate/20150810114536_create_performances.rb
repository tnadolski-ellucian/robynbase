class CreatePerformances < ActiveRecord::Migration
  def change
    create_table :performances, :id => false do |t|
      t.integer :performanceid, :primary => true
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
      t.belongs_to :song, foreign_key: 'SONGID', index: true
      t.belongs_to :performance, foreign_key: 'performanceid', index: true
      t.timestamps null: false
    end

  end
end