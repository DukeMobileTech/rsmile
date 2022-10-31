# == Schema Information
#
# Table name: raffles
#
#  id                :bigint           not null, primary key
#  participant_id    :integer
#  completion_entry  :boolean          default(FALSE)
#  recruitment_entry :boolean          default(TRUE)
#  recruitee_code    :string
#  response_uuid     :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
class Raffle < ApplicationRecord
  belongs_to :participant
end
