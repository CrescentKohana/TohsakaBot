class AddTimezoneColumnToReminder < ActiveRecord::Migration[7.0]
  def change
    add_column :reminders, :timezone, :string, null: true
  end
end
