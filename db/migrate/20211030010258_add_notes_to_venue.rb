class AddNotesToVenue < ActiveRecord::Migration[5.2]
  def change
    add_column :VENUE, :Notes, :text
  end
end
