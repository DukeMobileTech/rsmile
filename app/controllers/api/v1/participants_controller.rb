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
    @participant = Participant.new(participant_params)
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
    @participant = Participant.find(params[:id]) unless params[:id].blank?
    @participant = Participant.find_by(email: sanitized_email) if @participant.nil? && !sanitized_email.blank?

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

  def check
    @participant = Participant.find_by(code: params[:code])
    if params[:code].blank? || @participant.nil? || @participant.raffle_quota_met
      render json: { continue: false }, status: :ok
    else
      render json: { continue: true }, status: :ok
    end
  end

  private

  def participant_params
    params.fetch(:participant, {}).permit(:email, :phone_number, :country, :self_generated_id,
                                          :rds_id, :code, :referrer_code, :sgm_group,
                                          :referrer_sgm_group, :match, :quota, :name,
                                          :preferred_contact_method, :verification_code,
                                          :seed, :enter_raffle, :remind, :seed_id)
  end

  def sanitized_email
    params[:email]&.downcase&.strip
  end
end
