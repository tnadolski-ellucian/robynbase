class IncreaseGuestColumnSize < ActiveRecord::Migration[5.2]
  def up
    change_column :GIG, :Guests, :string, :limit => 512
  end

  def down
    change_column :GIG, :Guests, :string, :limit => 150
  end
end
