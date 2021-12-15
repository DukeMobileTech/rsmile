class SurveyResponsesController < ApplicationController
  def sources
    render json: SurveyResponse.survey_sources(params[:country])
  end
end
