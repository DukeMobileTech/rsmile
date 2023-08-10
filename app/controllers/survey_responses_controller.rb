class SurveyResponsesController < ApplicationController
  def baselines
    render json: SurveyResponse.baseline_stats(params[:country])
  end

  def progress
    render json: SurveyResponse.progress_stats(params[:country])
  end
end
