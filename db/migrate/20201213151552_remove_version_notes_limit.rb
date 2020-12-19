class RemoveVersionNotesLimit < ActiveRecord::Migration[5.2]
  def up
    change_column :GSET, :VersionNotes, :string, :limit => nil
  end

  def down
    change_column :GSET, :VersionNotes, :string, :limit => 32
  end
end
