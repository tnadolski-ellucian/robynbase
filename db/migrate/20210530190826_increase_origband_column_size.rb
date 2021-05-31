class IncreaseOrigbandColumnSize < ActiveRecord::Migration[5.2]
  def up
    change_column :SONG, :OrigBand, :string, :limit => 128
  end

  def down
    change_column :SONG, :OrigBand, :string, :limit => 32
  end
end
