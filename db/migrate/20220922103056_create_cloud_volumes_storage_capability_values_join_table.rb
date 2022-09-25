class CreateCloudVolumesStorageCapabilityValuesJoinTable < ActiveRecord::Migration[6.1]
  def change
    create_join_table :cloud_volumes ,:storage_capability_values
  end
end
