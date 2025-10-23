class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products, id: :uuid do |t|
      t.string :name
      t.boolean :publish
      t.belongs_to :category, type: :uuid, foreign_key: true

      t.timestamps
    end
  end
end
