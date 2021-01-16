class RemoveAuthorLimit < ActiveRecord::Migration[5.2]
  def up
    change_column :SONG, :Author, :string, :limit => nil
  end

  def down
    change_column :SONG, :Author, :string, :limit => 40
  end
end
