class AddIdHashColumnToLinkeds < ActiveRecord::Migration[7.0]
  def change
    add_column :linkeds, :idhash, :string, null: true, :after => :file_hash
  end
end
