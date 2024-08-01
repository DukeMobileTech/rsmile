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
#  message        :text
#
class Reminder < ApplicationRecord
  belongs_to :participant

  def self.ransackable_attributes(_auth_object = nil)
    Reminder.column_names
  end

  def self.ransackable_associations(_auth_object = nil)
    [:participant]
  end
end
