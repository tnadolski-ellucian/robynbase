class AddMediaLinkToGset < ActiveRecord::Migration[5.2]
  def change
    add_column :GSET, :MediaLink, :string
  end
end
