# == Schema Information
#
# Table name: email_logs
#
#  id         :bigint           not null, primary key
#  recipient  :string
#  subject    :string
#  message    :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class EmailLog < ApplicationRecord
  def self.ransackable_attributes(_auth_object = nil)
    EmailLog.column_names
  end
end
