# rubocop:disable Style/ClassAndModuleChildren
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

  # rubocop:disable Metrics/AbcSize
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
  # rubocop:enable Metrics/AbcSize

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
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
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  # Check whether a seed participant is allowed to invite other participants.
  def check
    participant = Participant.find_by(code: params[:code])
    if participant.nil? || !participant.seed || participant.quota_met ||
       participant.invite_expired? || !participant.sgm_group_enrolling
      render json: { continue: false, sgm_group: nil, id: nil, country: nil },
             status: :ok
    else
      render json: { continue: true, sgm_group: participant.sgm_group_label,
                     id: participant.id, country: participant.country },
             status: :ok
    end
  end

  # Check whether a participant is allowed to invite other participants.
  def referrer_check
    participant = Participant.find_by(code: params[:code])
    if participant.nil? || participant.quota_met || participant.invite_expired? || !participant.sgm_group_enrolling
      render json: { continue: false, sgm_group: nil, country: nil },
             status: :ok
    else
      render json: { continue: true, sgm_group: participant.sgm_group,
                     country: participant.country },
             status: :ok
    end
  end

  def referrer
    participant = Participant.find(params[:id])
    render json: { referrer_sgm_group: nil, match: nil, quota_met: nil, group_enrolling: nil, derived_seed: nil }, status: :not_found if participant.nil?
    recruiter = participant.recruiter
    render json: { referrer_sgm_group: nil, match: nil, quota_met: nil, group_enrolling: nil, derived_seed: nil }, status: :not_found if recruiter.nil?
    render json: {
      referrer_sgm_group: recruiter.sgm_group, quota_met: recruiter.quota_met,
      match: participant.match, group_enrolling: participant.sgm_group_enrolling,
      derived_seed: participant.derived_seed
    }, status: :ok
  end

  # Checks whether the participant's recruiter has met their quota. If the recruiter
  # has met their quota, the participant is not allowed to invite other participants.
  def recruitment
    participant = Participant.find(params[:id])
    if params[:id].blank? || participant.nil? || participant.recruiter.nil?
      render json: { sgm_group: nil, quota_met: nil, code: nil }, status: :not_found
    else
      render json: { sgm_group: participant.sgm_group_label,
                     quota_met: participant.recruiter_quota_met?, code: participant.code },
             status: :ok
    end
  end

  def email_check
    participant = Participant.find_by(email: sanitized_email)
    if participant&.previous_participant
      render json: { exists: true, id: participant.id }, status: :ok
    else
      render json: { exists: false, id: nil }, status: :ok
    end
  end

  def phone_check
    participant = Participant.find_by(phone_number: sanitized_phone)
    if participant&.previous_participant
      render json: { exists: true, id: participant.id }, status: :ok
    else
      render json: { exists: false, id: nil }, status: :ok
    end
  end

  private

  def participant_params
    params.fetch(:participant, {}).permit(:email, :phone_number, :country, :self_generated_id, :agree_to_recruit,
                                          :wants_payment, :rds_id, :code, :referrer_code, :sgm_group,
                                          :referrer_sgm_group, :match, :language, :contact, :language_code,
                                          :preferred_contact_method, :verification_code, :seed, :remind)
  end

  def sanitized_email
    params[:email]&.downcase&.strip
  end

  def sanitized_phone
    Phonelib.parse(params[:phone_number]).full_e164
  end
end
