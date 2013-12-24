class CreateProteins < ActiveRecord::Migration
  def change
    create_table :proteins do |t|
      t.string :gene_id
      t.string :search_gene_id
      t.integer :organism
      t.string :symbols
      t.string :description
      t.decimal :weight
      t.string :arabi_gene_id
      t.string :arabi_symbols
      t.string :arabi_description

      t.timestamps
    end
  end
end
