class CreateBirds < ActiveRecord::Migration[7.1]
  def change
    create_table :birds do |t|
      t.text :name
      t.references :nodes, foreign_key: true, index: true
    end
  end
end
