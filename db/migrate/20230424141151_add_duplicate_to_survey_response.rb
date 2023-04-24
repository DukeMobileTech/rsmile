class AddDuplicateToSurveyResponse < ActiveRecord::Migration[6.1]
  def change
    add_column :survey_responses, :duplicate, :boolean, default: false
    add_column :participants, :include, :boolean, default: true
  end
end
