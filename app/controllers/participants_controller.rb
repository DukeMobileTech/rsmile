class ParticipantsController < ApplicationController
  def index
    render json: Participant.summary_stats
  end

  def eligible_sgm_stats
    render json: Participant.eligible_sgm_stats(params[:country])
  end

  def ineligible_sgm_stats
    render json: Participant.ineligible_sgm_stats(params[:country])
  end

  def grouped
    render json: Participant.weekly_statistics(params[:country])
  end

  def blank_stats
    render json: Participant.blank_stats(params[:country])
  end
end
