class CreateGigMedia < ActiveRecord::Migration[5.2]
  def change
    create_table :gigmedia do |t|
      t.integer :GIGID
      t.string  :title
      t.string  :mediaid
      t.integer :mediatype, limit: 2
      t.integer :showplaylist, limit: 1, default: 0
      t.integer :Chrono,    default: 10

      t.timestamps
    end
  end
end
