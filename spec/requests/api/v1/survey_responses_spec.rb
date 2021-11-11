require 'swagger_helper'

RSpec.describe 'api/v1/survey_responses', type: :request do

  path '/api/v1/survey_responses' do

    # get('list survey_responses') do
    #   response(200, 'successful') do
    #
    #     after do |example|
    #       example.metadata[:response][:content] = {
    #         'application/json' => {
    #           example: JSON.parse(response.body, symbolize_names: true)
    #         }
    #       }
    #     end
    #     run_test!
    #   end
    # end

    post('create survey_response') do
      consumes 'application/json'
      produces 'application/json'
      security [{ bearer: [] }]
      parameter name: :survey_response, in: :body, schema: {
        type: :object,
        properties: {
          survey_uuid: { type: :string },
          response_uuid: { type: :string },
          survey_complete: { type: :boolean },
          survey_title: { type: :string },
          country: { type: :string },
          eligible: { type: :boolean },
          consented: { type: :boolean }
        }
      }

      response(200, 'successful') do

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end
        run_test!
      end
    end
  end


  path '/api/v1/survey_responses/amend' do
    put('update survey_response attributes') do
      consumes 'application/json'
      produces 'application/json'
      security [{ bearer: [] }]
      parameter name: :survey_response, in: :body, schema: {
        type: :object,
        properties: {
          survey_uuid: { type: :string },
          response_uuid: { type: :string },
          survey_complete: { type: :boolean },
          survey_title: { type: :string },
          country: { type: :string },
          eligible: { type: :boolean },
          consented: { type: :boolean }
        },
        required: [ 'response_uuid' ]
      }

      response(200, 'successful') do

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end
        run_test!
      end
    end
  end

  # path '/api/v1/survey_responses/new' do
  #
  #   get('new survey_response') do
  #     response(200, 'successful') do
  #
  #       after do |example|
  #         example.metadata[:response][:content] = {
  #           'application/json' => {
  #             example: JSON.parse(response.body, symbolize_names: true)
  #           }
  #         }
  #       end
  #       run_test!
  #     end
  #   end
  # end

  # path '/api/v1/survey_responses/{id}/edit' do
  #   # You'll want to customize the parameter types...
  #   parameter name: 'id', in: :path, type: :string, description: 'id'
  #
  #   get('edit survey_response') do
  #     response(200, 'successful') do
  #       let(:id) { '123' }
  #
  #       after do |example|
  #         example.metadata[:response][:content] = {
  #           'application/json' => {
  #             example: JSON.parse(response.body, symbolize_names: true)
  #           }
  #         }
  #       end
  #       run_test!
  #     end
  #   end
  # end

  # path '/api/v1/survey_responses/{id}' do
  #   # You'll want to customize the parameter types...
  #   parameter name: 'id', in: :path, type: :string, description: 'id'
  #
  #   get('show survey_response') do
  #     response(200, 'successful') do
  #       let(:id) { '123' }
  #
  #       after do |example|
  #         example.metadata[:response][:content] = {
  #           'application/json' => {
  #             example: JSON.parse(response.body, symbolize_names: true)
  #           }
  #         }
  #       end
  #       run_test!
  #     end
  #   end
  #
  #   patch('update survey_response') do
  #     response(200, 'successful') do
  #       let(:id) { '123' }
  #
  #       after do |example|
  #         example.metadata[:response][:content] = {
  #           'application/json' => {
  #             example: JSON.parse(response.body, symbolize_names: true)
  #           }
  #         }
  #       end
  #       run_test!
  #     end
  #   end
  #
  #   put('update survey_response') do
  #     response(200, 'successful') do
  #       let(:id) { '123' }
  #
  #       after do |example|
  #         example.metadata[:response][:content] = {
  #           'application/json' => {
  #             example: JSON.parse(response.body, symbolize_names: true)
  #           }
  #         }
  #       end
  #       run_test!
  #     end
  #   end
  #
  #   delete('delete survey_response') do
  #     response(200, 'successful') do
  #       let(:id) { '123' }
  #
  #       after do |example|
  #         example.metadata[:response][:content] = {
  #           'application/json' => {
  #             example: JSON.parse(response.body, symbolize_names: true)
  #           }
  #         }
  #       end
  #       run_test!
  #     end
  #   end
  # end
end
