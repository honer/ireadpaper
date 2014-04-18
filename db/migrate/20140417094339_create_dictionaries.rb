class CreateDictionaries < ActiveRecord::Migration
  def change
    create_table :dictionaries do |t|
      t.string :en
      t.string :zhtw

      t.timestamps
    end
  end
end
