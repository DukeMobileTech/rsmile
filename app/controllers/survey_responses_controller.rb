class SurveyResponsesController < ApplicationController
  def sources
    render json: SurveyResponse.survey_sources(params[:country])
  end

  def consents
    render json: SurveyResponse.consent_stats(params[:country])
  end

  def baselines
    render json: SurveyResponse.baseline_stats(params[:country])
  end

  def sources_timeline
    render json: SurveyResponse.sources_timeline(params[:country])
  end
end
