class RemoveSongNameLimit < ActiveRecord::Migration[5.2]
  def up
    change_column :GSET, :Song, :string, :limit => nil
    change_column :SONG, :Song, :string, :limit => nil
    change_column :TRAK, :Song, :string, :limit => nil
  end

  def down
    change_column :GSET, :Song, :string, :limit => 64
    change_column :SONG, :Song, :string, :limit => 64
    change_column :TRAK, :Song, :string, :limit => 64
  end
end
