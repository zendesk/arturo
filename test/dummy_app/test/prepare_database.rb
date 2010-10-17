require 'active_record'

ActiveRecord::Base.establish_connection({
  :adapter  => 'sqlite3',
  :database => ':memory:'
})

ActiveRecord::Schema.define do
  create_table :features do |t|
    t.string   :name, :null => false
    t.integer  :deployment_percentage, :null => false
    t.timestamps
  end
end
