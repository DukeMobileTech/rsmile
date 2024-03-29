class SurveyMetadataJob < ApplicationJob
  queue_as :rs_qualtrics

  def perform(survey_response_id)
    survey_response = SurveyResponse.where(id: survey_response_id).first
    survey_response&.fetch_qualtrics_data
  end
end
