class CreateProjects < ActiveRecord::Migration[8.1]
  def change
    create_table :projects do |t|
      t.string :name, null: false
      t.date :starts_on, null: false

      t.timestamps
    end
  end
end
