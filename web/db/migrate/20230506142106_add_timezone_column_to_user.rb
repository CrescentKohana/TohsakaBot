class AddTimezoneColumnToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :timezone, :string, null: true
  end
end
