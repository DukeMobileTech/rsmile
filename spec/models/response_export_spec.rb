# == Schema Information
#
# Table name: response_exports
#
#  id               :bigint           not null, primary key
#  country          :string
#  survey_id        :string
#  progress_id      :string
#  percent_complete :decimal(, )
#  status           :string
#  file_id          :string
#  file_path        :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
require 'rails_helper'

RSpec.describe ResponseExport, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
