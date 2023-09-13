class SurveyResponsesController < ApplicationController
  def baselines
    render json: SurveyResponse.baseline_stats(params[:country])
  end

  def progress
    render json: SurveyResponse.progress_stats(params[:country])
  end

  def mobilizers
    render json: SurveyResponses::Mobilizer.new.stats(params[:country])
  end

  def agencies
    render json: SurveyResponses::Agency.new.stats(params[:country])
  end

  def sources
    render json: SurveyResponses::Source.new.stats(params[:country])
  end

  def timeline
    render json: SurveyResponses::Source.new.timeline(params[:country])
  end
end
