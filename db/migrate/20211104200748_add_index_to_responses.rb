class AddIndexToResponses < ActiveRecord::Migration[6.1]
  def change
    add_index :survey_responses, :response_uuid, unique: true
  end
end
