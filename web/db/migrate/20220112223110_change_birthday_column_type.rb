class ChangeBirthdayColumnType < ActiveRecord::Migration[7.0]
  def change
    change_column :users, :birthday, :text
  end
end
