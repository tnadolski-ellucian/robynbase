class ChangeShortNoteToText < ActiveRecord::Migration[5.2]
  def up
    change_column :GIG, :ShortNote, :text
  end
  
  def down
    change_column :GIG, :ShortNote, :string, :limit => 64
  end
end
