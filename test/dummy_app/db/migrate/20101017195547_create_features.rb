require 'active_support/core_ext'

class CreateFeatures < ActiveRecord::Migration
  def self.up
    create_table :features do |t|
      t.string   :symbol, :null => false
      t.integer  :deployment_percentage, :null => false
      t.string   :class_name, :null => false, :default => "Arturo::Feature"
      #Any additional fields here

      t.timestamps
    end
  end

  def self.down
    drop_table :features
  end
end
