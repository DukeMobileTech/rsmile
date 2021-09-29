class ParticipantSerializer < ActiveModel::Serializer
  attributes :id, :email, :phone_number, :country, :self_generated_id, :study_id,
    :rds_id, :code, :referrer_code, :sgm_group, :referrer_sgm_group
end
