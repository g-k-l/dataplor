class Addforeignkey < ActiveRecord::Migration[7.1]
  def change
    add_foreign_key :nodes, :nodes, column: :parent_id
  end
end
