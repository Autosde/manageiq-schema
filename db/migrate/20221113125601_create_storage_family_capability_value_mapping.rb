class CreateStorageFamilyCapabilityValueMapping < ActiveRecord::Migration[6.1]
  def change
    create_table :storage_family_capability_value_mappings do |t|

      t.references :ems, :type => :bigint, :index => true, :references => :ext_management_system
      t.string :ems_ref
      t.references :physical_storage_family, :type => :bigint, :index => {:name => :index_family_cap_val_on_physical_storage_family_id}
      t.references :storage_capability_value, :type => :bigint, :index => {:name => :index_family_cap_val_on_storage_capability_value_id}
      t.timestamps    end
  end
end
