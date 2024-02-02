class AddAgreeToRecruitToParticipants < ActiveRecord::Migration[6.1]
  def change
    add_column :participants, :agree_to_recruit, :boolean, default: true
    add_column :participants, :wants_payment, :boolean, default: true
    remove_column :participants, :study_id, :string
    remove_column :participants, :quota, :integer
  end
end
