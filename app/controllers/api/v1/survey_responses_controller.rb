class Api::V1::SurveyResponsesController < Api::ApiController
  def create
    @survey_response = SurveyResponse.where(response_uuid: params[:response_uuid]).first_or_initialize(survey_response_params)
    @survey_response.assign_attributes(survey_response_params)
    if @survey_response.save
      render json: @survey_response, status: :created
    else
      render json: @survey_response.errors, status: :unprocessable_entity
    end
  end

  def amend
    if !params[:response_uuid].blank?
      @survey_response = SurveyResponse.find_by(response_uuid: params[:response_uuid])
      @survey_response ||= SurveyResponse.create(survey_response_params)
    elsif !params[:id].blank?
      @survey_response = SurveyResponse.find(params[:id])
    end

    render json: { error: 'not found' }, status: :not_found if @survey_response.nil?

    if @survey_response.update(survey_response_params)
      render json: @survey_response, status: :ok
    else
      render json: @survey_response.errors, status: :unprocessable_entity
    end
  end

  def safety
    content_hash = JSON.parse params[:responses]
    language = content_hash['language']&.downcase&.strip
    pdf = SafetyPlan.new(content_hash)
    file = Tempfile.new('Safety Planning')
    pdf.save_as(file.path)
    begin
      SafetyMailer.with(filename: file.path, email: content_hash['email']&.downcase&.strip,
                        language: language).safety_planning_form.deliver_now
      render json: { email: 'sent' }, status: :ok
    rescue Exception
      render json: { email: 'failed' }, status: :unprocessable_entity
    end
  end

  private

  def survey_response_params
    params.fetch(:survey_response, {}).permit(:participant_id, :survey_uuid,
                                              :response_uuid, :survey_complete,
                                              :survey_title, :country, :consented,
                                              :eligible, :metadata, :language, :source,
                                              :sgm_group, :ip_address, :duration,
                                              :birth_year, :age)
  end
end
