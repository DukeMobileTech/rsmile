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
require 'rails_helper'

RSpec.describe Invite, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
