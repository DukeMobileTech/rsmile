class AddVerificationCodeToParticipant < ActiveRecord::Migration[6.1]
  def change
    add_column :participants, :verification_code, :string
  end
end
