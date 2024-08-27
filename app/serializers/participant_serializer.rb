# == Schema Information
#
# Table name: participants
#
#  id                       :bigint           not null, primary key
#  email                    :string
#  phone_number             :string
#  country                  :string
#  self_generated_id        :string
#  rds_id                   :string
#  code                     :string
#  referrer_code            :string
#  sgm_group                :string
#  referrer_sgm_group       :string
#  match                    :boolean          default(FALSE)
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  preferred_contact_method :string
#  verified                 :boolean          default(FALSE)
#  verification_code        :string
#  include                  :boolean          default(TRUE)
#  seed                     :boolean          default(FALSE)
#  remind                   :boolean          default(TRUE)
#  quota_met                :boolean          default(FALSE)
#  baseline_participant_id  :integer
#  agree_to_recruit         :boolean          default(TRUE)
#  wants_payment            :boolean          default(TRUE)
#  opt_out                  :boolean          default(FALSE)
#  due_on                   :datetime
#  derived_seed             :boolean          default(FALSE)
#  chain_level              :integer          default(0)
#  language_code            :string           default("en")
#  alternate_phone_number   :string
#  alternate_seed           :boolean          default(FALSE)
#
class ParticipantSerializer < ActiveModel::Serializer
  attributes :id, :email, :phone_number, :country, :self_generated_id, :wants_payment, :agree_to_recruit,
             :rds_id, :code, :referrer_code, :sgm_group, :referrer_sgm_group, :match, :quota_met,
             :preferred_contact_method, :verified, :verification_code, :include, :seed, :remind
end
