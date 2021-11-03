class AddContactMethodToParticipant < ActiveRecord::Migration[6.1]
  def change
    add_column :participants, :preferred_contact_method, :string
    add_column :participants, :verified, :boolean, default: false
    add_column :survey_responses, :survey_title, :string
  end
end
