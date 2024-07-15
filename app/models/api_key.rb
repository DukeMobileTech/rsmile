# == Schema Information
#
# Table name: api_keys
#
#  id           :bigint           not null, primary key
#  bearer_id    :integer          not null
#  bearer_type  :string           not null
#  token_digest :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
class ApiKey < ApplicationRecord
  HMAC_SECRET_KEY = Rails.application.credentials.config[:API_KEY_HMAC_SECRET_KEY]
  belongs_to :bearer, polymorphic: true
  before_create :generate_token_hmac_digest
  attr_accessor :token

  def self.authenticate_by_token!(token)
    digest = OpenSSL::HMAC.hexdigest 'SHA256', HMAC_SECRET_KEY, token
    find_by! token_digest: digest
  end

  def self.authenticate_by_token(token)
    authenticate_by_token! token
    rescue ActiveRecord::RecordNotFound
      nil
  end

  def serializable_hash(options = nil)
    h = super options.merge(except: 'token_digest')
    h.merge! 'token' => token if token.present?
    h
  end

  def self.ransackable_associations(auth_object = nil)
    ["bearer"]
  end

  def self.ransackable_attributes(auth_object = nil)
    ["bearer_id", "bearer_type", "created_at", "id", "token_digest", "updated_at"]
  end

  private

  def generate_token_hmac_digest
    raise ActiveRecord::RecordInvalid, 'token is required' unless token.present?
    digest = OpenSSL::HMAC.hexdigest 'SHA256', HMAC_SECRET_KEY, token
    self.token_digest = digest
  end

end
