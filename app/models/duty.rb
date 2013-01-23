class Duty < ActiveRecord::Base
  attr_accessible :type, :start_time, :end_time, :aircraft, :from, :to

  def to_s
    string = ''
    string.concat "type: #{type}\n" unless type.blank?
    string.concat "start: #{start_time}\n" unless start_time.blank?
    string.concat "end #{end_time}\n" unless end_time.blank?
    string.concat "from: #{from}\n" unless from.blank?
    string.concat "to: #{to}\n" unless to.blank?
    string.concat "aircraft: #{aircraft}" unless aircraft.blank?

    string
  end
end