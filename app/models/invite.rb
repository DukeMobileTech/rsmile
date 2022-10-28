# == Schema Information
#
# Table name: invites
#
#  id          :bigint           not null, primary key
#  first_name  :string
#  last_name   :string
#  email       :string
#  invite_code :string(40)
#  invited_at  :datetime
#  redeemed_at :datetime
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  admin       :boolean          default(FALSE)
#
class Invite < ApplicationRecord
  scope :unsent_invitations, -> { where({ redeemed_at: nil, invite_code: nil }) }
  validates :email, presence: true, uniqueness: true

  def invited?
    !!self.invite_code && !!self.invited_at
  end

  def invite!
    self.invite_code = Digest::SHA1.hexdigest("--#{Time.now.utc.to_s}--#{self.email}--")
    self.invited_at = Time.now.utc
    self.save!
  end

  def self.find_redeemable(invite_code)
    self.find_by(redeemed_at: nil, invite_code: invite_code)
  end

  def redeemed!
    self.redeemed_at = Time.now.utc
    self.save!
  end

  def user_exists?
    User.find_by(email: self.email)
  end

end
