class IncreaseGigColumnSizes < ActiveRecord::Migration[5.2]
  def up
    change_column :GIG, :BilledAs, :string, :limit => 75
    change_column :GIG, :Guests, :string, :limit => 150
  end

  def down
    change_column :GIG, :BilledAs, :string, :limit => 32
    change_column :GIG, :Guests, :string, :limit => 64
  end
end
