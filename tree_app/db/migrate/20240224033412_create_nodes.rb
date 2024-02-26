class CreateNodes < ActiveRecord::Migration[7.1]
  def change
    create_table :nodes do |t|
      # an int id column is created by default
      t.integer :parent_id
    end
    # id is a PK, which is automatically indexed
    add_index :nodes, :parent_id
  end
end
