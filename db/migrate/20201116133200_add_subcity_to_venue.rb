class AddSubcityToVenue < ActiveRecord::Migration[5.2]
  def change
    add_column :VENUE, :SubCity, :string
  end
end
