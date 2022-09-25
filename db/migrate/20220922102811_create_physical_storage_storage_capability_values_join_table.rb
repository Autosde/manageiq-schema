class CreatePhysicalStorageStorageCapabilityValuesJoinTable < ActiveRecord::Migration[6.1]
  def change
    create_join_table :physical_storages ,:storage_capability_values
  end
end
