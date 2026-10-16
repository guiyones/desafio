class CreateGroups < ActiveRecord::Migration[8.1]
  def change
    create_table :groups do |t|
      t.references :project, null: false, foreign_key: true
      t.string :name, null: false

      t.timestamps
    end
  end
end
