class CreateMaterialweights < ActiveRecord::Migration
  def change
    create_table :materialweights do |t|
      t.integer :gel_no
      t.decimal :weight
      t.references :material, index: true

      t.timestamps
    end
  end
end
