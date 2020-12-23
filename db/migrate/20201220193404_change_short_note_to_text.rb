class ChangeShortNoteToText < ActiveRecord::Migration[5.2]
  def up
    change_column :Gig, :ShortNote, :text
  end
  
  def down
    change_column :Gig, :ShortNote, :string, :limit => 64
  end
end
