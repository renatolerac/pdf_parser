class AddDetailsToDuties < ActiveRecord::Migration
  def change
    add_column :duties, :type, :string
    add_column :duties, :start_time, :datetime
    add_column :duties, :end_time, :datetime
    add_column :duties, :aircraft, :string
    add_column :duties, :from, :string
    add_column :duties, :to, :string
  end
end
