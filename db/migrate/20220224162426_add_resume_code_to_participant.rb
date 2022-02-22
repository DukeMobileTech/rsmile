class AddResumeCodeToParticipant < ActiveRecord::Migration[6.1]
  def change
    add_column :participants, :resume_code, :string
    add_index :participants, :resume_code, unique: true
  end
end
