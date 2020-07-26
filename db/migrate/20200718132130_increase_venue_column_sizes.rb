class IncreaseVenueColumnSizes < ActiveRecord::Migration[5.2]
  def up
    change_column :VENUE, :State, :string, :limit => 50
    change_column :VENUE, :Country, :string, :limit => 50
    change_column :VENUE, :City, :string, :limit => 50
  end

  def down
    change_column :VENUE, :State, :string, :limit => 16
    change_column :VENUE, :Country, :string, :limit => 16
    change_column :VENUE, :City, :string, :limit => 24
  end
end
