class CreateCommands < ActiveRecord::Migration[6.1]
  def change
    create_table :commands do |t|
      t.string :text
      t.integer :status, default: 1
      t.string :job_id
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
