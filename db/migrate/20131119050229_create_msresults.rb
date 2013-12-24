class CreateMsresults < ActiveRecord::Migration
  def change
    create_table :msresults do |t|
      t.string :gene_id
      t.integer :gel_no
      t.decimal :empai
      t.decimal :empai_rt
      t.integer :peak
      t.references :material, index: true
      t.references :protein, index: true

      t.timestamps
    end
  end
end
