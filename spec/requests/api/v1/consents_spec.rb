require 'swagger_helper'

RSpec.describe 'api/v1/consents', type: :request do
  path '/api/v1/consents' do
    post('send consent form') do
      consumes 'application/json'
      produces 'application/json'
      security [{ bearer: [] }]
      parameter name: :participant, in: :body, schema: {
        type: :object,
        properties: {
          language: { type: :string },
          email: { type: :string },
          country: { type: :string }
        },
        required: %w[language email country]
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
end
