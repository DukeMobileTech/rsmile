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
    @survey_response = SurveyResponse.find_by(response_uuid: params[:response_uuid])
    if @survey_response.update(survey_response_params)
      render json: @survey_response, status: :ok
    else
      render json: @survey_response.errors, status: :unprocessable_entity
    end
  end
  
  private

  def survey_response_params
    params.fetch(:survey_response, {}).permit(:survey_uuid, :response_uuid,
      :survey_complete, :survey_title, :country, :consented, :eligible
    )
  end
end
