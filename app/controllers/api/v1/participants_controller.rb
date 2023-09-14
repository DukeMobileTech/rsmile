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
    @participant = Participant.where(email: sanitized_email).first_or_initialize(participant_params)
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
    unless params[:c_survey_uuid].blank? && params[:c_response_uuid].blank?
      response = SurveyResponse.find_by(response_uuid: params[:c_response_uuid])
      if response
        response.update(survey_complete: params[:c_survey_complete],
                        survey_title: params[:c_survey_title])
      else
        @participant.survey_responses.build(
          survey_uuid: params[:c_survey_uuid],
          response_uuid: params[:c_response_uuid],
          survey_complete: params[:c_survey_complete],
          survey_title: params[:c_survey_title]
        )
      end
    end
    if @participant.save
      @participant.send_verification_message(params[:language])
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
    participant = Participant.find(params[:id])
    render json: { error: 'not found' }, status: :not_found if participant.nil?

    status = participant.verify(params[:verification_code])
    if status == 'approved'
      render json: { token: 'approved' }, status: :ok
    else
      render json: { token: 'pending' }, status: :not_found
    end
  end

  def amend
    @participant = Participant.find(params[:id]) if params[:id].present?
    @participant = Participant.find_by(email: sanitized_email) if @participant.nil? && sanitized_email.present?

    if @participant.nil?
      render json: { error: 'not found' }, status: :not_found
    elsif @participant.update(participant_params)
      render json: @participant, status: :ok
    else
      render json: @participant.errors, status: :unprocessable_entity
    end
  end

  def update_and_resend
    @participant = Participant.find(params[:id])
    if params[:contact].include? '@'
      @participant.email = params['contact']&.downcase&.strip
      @participant.preferred_contact_method = '1'
    elsif params[:contact].include? '+'
      @participant.phone_number = params['contact']&.strip
      @participant.preferred_contact_method = '2'
    end

    render json: { error: 'not found' }, status: :not_found if @participant.nil?

    if @participant.save
      @participant.send_verification_message(params[:language])
      render json: @participant, status: :ok
    else
      render json: @participant.errors, status: :unprocessable_entity
    end
  end

  private

  def participant_params
    params.fetch(:participant, {}).permit(:email, :phone_number, :country, :self_generated_id,
                                          :study_id, :rds_id, :code, :referrer_code, :sgm_group,
                                          :referrer_sgm_group, :match, :quota, :language, :contact,
                                          :preferred_contact_method, :verification_code, :seed, :remind)
  end

  def sanitized_email
    params[:email]&.downcase&.strip
  end
end
