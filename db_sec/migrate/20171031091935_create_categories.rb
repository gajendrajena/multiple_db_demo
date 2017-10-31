class CreateCategories < ActiveRecord::Migration[5.1]
  def connection
    ActiveRecord::Base.establish_connection(DB_SEC).connection
  end

  def change
    create_table :categories do |t|
      t.string :name
      t.string :description

      t.timestamps
    end
  end
end
