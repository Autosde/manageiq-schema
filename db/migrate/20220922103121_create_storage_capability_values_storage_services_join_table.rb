class CreateStorageCapabilityValuesStorageServicesJoinTable < ActiveRecord::Migration[6.1]
  def change
    create_join_table :storage_capability_values, :storage_services
  end
end
