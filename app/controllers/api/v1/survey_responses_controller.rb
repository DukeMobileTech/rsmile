module Api
  module V1
    class SurveyResponsesController < Api::ApiController
      def create
        @survey_response = SurveyResponse.new(survey_response_params)
        if @survey_response.save
          render json: @survey_response, status: :created
        else
          render json: @survey_response.errors, status: :unprocessable_entity
        end
      end

      # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      def amend
        if params[:response_uuid].present?
          @survey_response = SurveyResponse.find_by(response_uuid: params[:response_uuid])
          @survey_response ||= SurveyResponse.create(survey_response_params)
        elsif params[:id].present?
          @survey_response = SurveyResponse.find(params[:id])
        end

        if @survey_response.nil?
          render json: { error: 'not found' }, status: :not_found
        elsif @survey_response.update(survey_response_params)
          render json: @survey_response, status: :ok
        else
          render json: @survey_response.errors, status: :unprocessable_entity
        end
      end
      # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

      # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
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
      # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

      def sync
        survey_response = SurveyResponse.find(params[:id])
        if survey_response&.rds_survey?
          SurveyMetadataJob.perform_later(survey_response.id)
          render json: { status: 'queued' }, status: :ok
        else
          render json: { error: 'not found' }, status: :not_found
        end
      end

      private

      def survey_response_params
        params.fetch(:survey_response, {}).permit(:participant_id, :survey_uuid,
                                                  :response_uuid, :survey_complete,
                                                  :survey_title, :country, :consented,
                                                  :eligible, :metadata, :language, :source,
                                                  :sgm_group, :ip_address, :duration,
                                                  :birth_year, :age, :gender_identity,
                                                  :sexual_orientation, :intersex, :sexual_attraction)
      end
    end
  end
end
