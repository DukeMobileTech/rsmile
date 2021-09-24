# == Schema Information
#
# Table name: participants
#
#  id                 :bigint           not null, primary key
#  email              :string
#  phone_number       :string
#  country            :string
#  self_generated_id  :string
#  study_id           :string
#  rds_id             :string
#  code               :string
#  referrer_code      :string
#  sgm_group          :string
#  referrer_sgm_group :string
#  match              :boolean
#  quota              :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
class Participant < ApplicationRecord
  has_many :survey_responses, dependent: :destroy
end
