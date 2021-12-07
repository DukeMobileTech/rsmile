class AddMetadataToSurveyResponse < ActiveRecord::Migration[6.1]
  def change
    enable_extension 'hstore' unless extension_enabled?('hstore')
    add_column :survey_responses, :metadata, :hstore
    add_index :survey_responses, :metadata, using: :gist
  end
end
