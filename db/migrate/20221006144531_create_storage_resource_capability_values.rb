class CreateStorageResourceCapabilityValues < ActiveRecord::Migration[6.1]
  def change
    create_table :storage_resource_capability_values do |t|
      t.references :ems, :type => :bigint, :index => true, :references => :ext_management_system
      t.string :ems_ref
      t.references :storage_resource, :type => :bigint, :index => {:name => :index_storage_resource_cap_val_on_physical_storage_id}
      t.references :storage_capability_value, :type => :bigint, :index => {:name => :index_storage_resource_cab_val_on_storage_capability_value_id}
      t.timestamps
    end
  end
end
