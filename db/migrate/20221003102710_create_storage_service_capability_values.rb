class CreateStorageServiceCapabilityValues < ActiveRecord::Migration[6.1]
  def change
    create_table :storage_service_capability_values do |t|
      t.references :storage_service, :type => :bigint, :index => {:name => :index_service_capability_value_on_storage_service_id}
      t.references :storage_capability_value, :type => :bigint, :index => {:name => :index_service_capability_value_on_storage_capability_value_id}
      t.timestamps
    end
  end
end
