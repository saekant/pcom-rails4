class CreateMaterials < ActiveRecord::Migration
  def change
    create_table :materials do |t|
      t.string :material_name
      t.string :grid_disp
      t.references :organism, index: true

      t.timestamps
    end
  end
end
