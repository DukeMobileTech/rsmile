# == Schema Information
#
# Table name: reminders
#
#  id             :bigint           not null, primary key
#  participant_id :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  category       :string
#  channel        :string
#
class Reminder < ApplicationRecord
  belongs_to :participant

  def self.ransackable_attributes(auth_object = nil)
    ["category", "channel", "created_at", "id", "participant_id", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["participant"]
  end
end
