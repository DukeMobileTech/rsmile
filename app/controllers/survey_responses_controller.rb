class SurveyResponsesController < ApplicationController
  def sources
    render json: SurveyResponse.survey_sources(params[:country])
  end

  def consents
    render json: SurveyResponse.consent_stats(params[:country])
  end
end
