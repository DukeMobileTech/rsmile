class ParticipantsController < ApplicationController
  def index
    render json: Participant.summary_stats
  end

  def sgm_groups
    render json: Participant.sgm_stats(params[:country])
  end

  def grouped
    render json: Participant.weekly_statistics(params[:country])
  end
end
