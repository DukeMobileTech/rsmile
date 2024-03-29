# == Schema Information
#
# Table name: participants
#
#  id                       :bigint           not null, primary key
#  email                    :string
#  phone_number             :string
#  country                  :string
#  self_generated_id        :string
#  study_id                 :string
#  rds_id                   :string
#  code                     :string
#  referrer_code            :string
#  sgm_group                :string
#  referrer_sgm_group       :string
#  match                    :boolean
#  quota                    :integer
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  preferred_contact_method :string
#  verified                 :boolean          default(FALSE)
#  resume_code              :string
#  verification_code        :string
#  include                  :boolean          default(TRUE)
#
class ParticipantSerializer < ActiveModel::Serializer
  attributes :id, :email, :phone_number, :country, :self_generated_id, :study_id,
             :rds_id, :code, :referrer_code, :sgm_group, :referrer_sgm_group, :match, :quota,
             :preferred_contact_method, :verified, :resume_code
end
