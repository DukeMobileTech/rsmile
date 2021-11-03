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
      response = SurveyResponse.find_by(response_uuid: params[:response_uuid])
      if response
        response.update(survey_complete: params[:survey_complete],
                                    survey_title: params[:survey_title])
      else
        @participant.survey_responses.build(
          survey_uuid: params[:survey_uuid],
          response_uuid: params[:response_uuid],
          survey_complete: params[:survey_complete],
          survey_title: params[:survey_title]
        )
      end
    end
    if @participant.save
      @participant.send_welcome_message
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

  def verify
    status = Participant.verify(params[:verification_code], params[:email])
    if status == "approved"
      render json: { token: "approved" }, status: :ok
    else
      render json: { token: "pending" }, status: :not_found
    end
  end

  def amend
    @participant = Participant.find_by(email: params[:email])
    if @participant.update(participant_params)
      render json: @participant, status: :ok
    else
      render json: @participant.errors, status: :unprocessable_entity
    end
  end

  private

  def participant_params
    params.fetch(:participant, {}).permit(:email, :phone_number, :country, :self_generated_id,
      :study_id, :rds_id, :code, :referrer_code, :sgm_group, :referrer_sgm_group, :match, :quota,
      :preferred_contact_method,
      survey_responses_attributes: [ :survey_uuid, :response_uuid, :survey_complete, :survey_title ]
    )
  end

end
