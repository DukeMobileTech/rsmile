class ParticipantsController < ApplicationController
  def index
    render json: Participant.summary_stats
  end
end
