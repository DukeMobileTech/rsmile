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
end