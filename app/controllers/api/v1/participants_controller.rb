class Api::V1::ParticipantsController < Api::ApiController
  def index
    @participants = Participant.all
    render json: @participants
  end

  def show
    @participant = Participant.find(params[:id])
    render json: @participant
  end

  def create
    @participant = Participant.where(email: params[:email]).first_or_initialize(participant_params)
    @participant.assign_attributes(participant_params)
    unless params[:survey_uuid].blank? && params[:response_uuid].blank?
      @participant.survey_responses.build(
        survey_uuid: params[:survey_uuid],
        response_uuid: params[:response_uuid],
        survey_complete: params[:survey_complete]
      )
    end
    if @participant.save
      render json: @participant, status: :created
    else
      render json: @participant.errors, status: :unprocessable_entity
    end
  end

  def update
    @participant = Participant.find(params[:id])
    if @participant.update(participant_params)
      render json: @participant, status: :ok
    else
      render json: @participant.errors, status: :unprocessable_entity
    end
  end

  private

  def participant_params
    params.fetch(:participant, {}).permit(:email, :phone_number, :country, :self_generated_id, :study_id,
      :rds_id, :code, :referrer_code, :sgm_group, :referrer_sgm_group, :match, :quota,
      survey_responses_attributes: [ :survey_uuid, :response_uuid, :survey_complete ]
    )
  end

end
