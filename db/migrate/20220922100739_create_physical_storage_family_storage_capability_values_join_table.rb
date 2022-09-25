class CreatePhysicalStorageFamilyStorageCapabilityValuesJoinTable < ActiveRecord::Migration[6.1]
  def change
    create_join_table :physical_storage_family ,:storage_capability_values
  end
end
