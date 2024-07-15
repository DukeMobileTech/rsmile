# == Schema Information
#
# Table name: users
#
#  id                 :bigint           not null, primary key
#  email              :string           not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  encrypted_password :string(128)
#  confirmation_token :string(128)
#  remember_token     :string(128)
#  admin              :boolean          default(FALSE)
#
class User < ApplicationRecord
  include Clearance::User

  has_many :api_keys, as: :bearer, dependent: :destroy

  def admin?
    admin
  end

  def self.ransackable_associations(auth_object = nil)
    ["api_keys"]
  end

  def self.ransackable_attributes(auth_object = nil)
    ["admin", "confirmation_token", "created_at", "email", "id", "remember_token", "updated_at"]
  end
end
