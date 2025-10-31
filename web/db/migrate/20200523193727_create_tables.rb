class CreateTables < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.integer :discriminator, null: true
      t.string :avatar, null: true
      t.string :locale, null: true
      t.timestamp :birthday, null: true
      t.integer :permissions, null: true

      t.timestamps
    end

    create_table :authorizations do |t|
      t.string :provider, null: false
      t.bigint :uid, null: false
      t.bigint :user_id, null: false

      t.timestamps
    end

    create_table :reminders do |t|
      t.datetime :datetime, null: false
      t.text :message, null: true
      t.bigint :user_id, null: false
      t.bigint :channel_id, null: true
      t.bigint :repeat, default: 0
      t.bigint :parent, null: true

      t.timestamps
    end

    create_table :triggers do |t|
      t.text :phrase, null: false
      t.text :reply, null: true
      t.text :file, null: true
      t.bigint :user_id, null: false
      t.bigint :server_id, null: false
      t.integer :chance, default: 0
      t.integer :mode, default: 0
      t.bigint :occurrences, null: false, default: 0
      t.bigint :calls, null: false, default: 0
      t.datetime :last_triggered, null: true

      t.timestamps
    end

    create_table :highlights do |t|
      t.text :content, null: true
      t.text :attachments, null: true
      t.bigint :author_id, null: false
      t.datetime :timestamp, null: false
      t.boolean :deleted, null: false
      t.bigint :msg_id, null: false
      t.bigint :channel_id, null: false
      t.bigint :server_id, null: false
      t.bigint :highlight_msg_id, null: false

      t.timestamps
    end

    create_table :linkeds do |t|
      t.text :category
      t.text :url
      t.datetime :timestamp
      t.text :file_hash
      t.bigint :author_id
      t.bigint :server_id
      t.bigint :channel_id
      t.bigint :msg_id

      t.timestamps
    end

    create_table :issues do |t|
      t.text :content, null: false
      t.integer :category, null: false, default: 0
      t.text :status, null: false, default: 'new'
      t.bigint :user_id, null: false
      t.bigint :server_id, null: false

      t.timestamps
    end

    create_table :trophies do |t|
      t.text :reason, null: false
      t.integer :duration, null: false
      t.integer :category, null: false, default: 0
      t.bigint :discord_uid, null: false
      t.bigint :server_id, null: false
      t.bigint :role_id, null: false
      t.boolean :expired, null: false, default: false

      t.timestamps
    end

    add_index :users, :name
    add_index :authorizations, :uid
    add_index :authorizations, :user_id
  end
end
