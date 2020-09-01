class CreateStorageSystems < ActiveRecord::Migration[5.1]
  def change
    create_table :storage_systems do |t|
      t.string :management_ip
      t.string :name
      t.string :secondary_ip
      t.string :storage_array
      t.string :storage_family
      t.references :storage_system_type, :type => :bigint, :index => true, :references => :storage_system_type
      t.string :uuid
      t.bigint :ems_id
      t.string :ems_ref

      t.timestamps
    end
  end
end
