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

  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "id", "message", "recipient", "subject", "updated_at"]
  end
end
