class Api::V1::ParticipantsController < ApiController
  def index
    @participants = Participant.all
  end

  def show
    @participant = Participant.find(params[:id])
  end
end
