class ParticipantsController < ApplicationController
  def index
    render json: Participants::Summary.new.stats
  end

  def eligible_sgm_stats
    render json: Participants::Sgm.new.eligible_stats(params[:country])
  end

  def ineligible_sgm_stats
    render json: Participants::Sgm.new.ineligible_stats(params[:country])
  end

  def grouped
    render json: Participant.weekly_statistics(params[:country])
  end

  def blank_stats
    render json: Participants::Sgm.new.blank_stats(params[:country])
  end

  def weekly_participants
    render json: Participant.weekly_participants
  end
end
