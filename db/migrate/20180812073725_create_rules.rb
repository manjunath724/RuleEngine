class CreateRules < ActiveRecord::Migration
  def change
    create_table :rules do |t|
      t.references :user, index: true, foreign_key: true
      t.string :signal
      t.string :value_type
      t.string :comparison_operator
      t.string :value
      t.boolean :relative

      t.timestamps null: false
    end
  end
end
