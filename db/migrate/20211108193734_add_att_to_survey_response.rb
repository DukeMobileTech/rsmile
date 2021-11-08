class AddAttToSurveyResponse < ActiveRecord::Migration[6.1]
  def change
    add_column :survey_responses, :country, :string
    add_column :survey_responses, :eligible, :boolean, default: true
    add_column :survey_responses, :consented, :boolean, default: true
  end
end
