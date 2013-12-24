class CreateOrganisms < ActiveRecord::Migration
  def change
    create_table :organisms do |t|
      t.string :organism_name

      t.timestamps
    end
  end
end
