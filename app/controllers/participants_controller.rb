class ParticipantsController < ApplicationController
  skip_before_action :require_login

  def index
    render json: Participant.summary_stats
  end
end
