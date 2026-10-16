class CreateSlips < ActiveRecord::Migration[8.1]
  def change
    create_table :slips do |t|
      t.references :challenge, null: false, foreign_key: true
      t.date :day, null: false
      t.text :note

      t.timestamps
    end

    add_index :slips, [ :challenge_id, :day ], unique: true
  end
end
