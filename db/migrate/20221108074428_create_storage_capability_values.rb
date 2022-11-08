class CreateStorageCapabilityValues < ActiveRecord::Migration[6.1]
  def change
    create_table :storage_capability_values do |t|
      t.references :ems, :type => :bigint, :index => true, :references => :ext_management_system
      t.references :storage_capability, :type => :bigint, :index => true
      t.string :value
      t.string :ems_ref
      t.timestamps
    end
  end
end
