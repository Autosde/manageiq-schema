class CreatePhysicalStorageCapabilityValueMapping < ActiveRecord::Migration[6.1]
  def change
    create_table :physical_storage_capability_value_mappings do |t|
      t.references :ems, :type => :bigint, :index => true, :references => :ext_management_system
      t.string :ems_ref
      t.references :physical_storage, :type => :bigint, :index => {:name => :index_physical_storage_cap_val_on_physical_storage_id}
      t.references :storage_capability_value, :type => :bigint, :index => {:name => :index_physical_storage_cap_val_on_storage_capability_value_id}
      t.timestamps
    end
  end
end
