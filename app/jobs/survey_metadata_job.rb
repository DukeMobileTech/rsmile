class SurveyMetadataJob < ApplicationJob
  queue_as :rds

  def perform(survey_response_id)
    survey_response = SurveyResponse.where(id: survey_response_id).first
    survey_response&.fetch_qualtrics_data
    survey_response&.participant&.update_recruiter_quota
  end
end
