class CreateChallenges < ActiveRecord::Migration[8.1]
  def change
    create_table :challenges do |t|
      t.references :group, null: false, foreign_key: true
      t.string :name, null: false

      t.timestamps
    end
  end
end
