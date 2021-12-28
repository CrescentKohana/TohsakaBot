class AddLastCongratulationColumnToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :last_congratulation, :integer, null: false, default: 0
  end
end
