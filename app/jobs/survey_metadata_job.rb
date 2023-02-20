class SurveyMetadataJob < ApplicationJob
  queue_as :default

  def perform(survey_response_id)
    survey_response = SurveyResponse.where(id: survey_response_id).first
    survey_response&.qualtrics_metadata
  end
end
