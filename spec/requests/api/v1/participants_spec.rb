require 'swagger_helper'

RSpec.describe 'api/v1/participants', type: :request do
  path '/api/v1/participants' do
    get('list participants') do
      security [{ bearer: [] }]
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

    post('create participant') do
      consumes 'application/json'
      produces 'application/json'
      security [{ bearer: [] }]
      parameter name: :participant, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string },
          phone_number: { type: :string },
          country: { type: :string },
          self_generated_id: { type: :string },
          rds_id: { type: :string },
          code: { type: :string },
          referrer_code: { type: :string },
          sgm_group: { type: :string },
          referrer_sgm_group: { type: :string },
          match: { type: :string },
          quota: { type: :string },
          preferred_contact_method: { type: :string },
          name: { type: :string }
        },
        required: %w[code]
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

  path '/api/v1/participants/verify' do
    post('verify participant') do
      consumes 'application/json'
      produces 'application/json'
      security [{ bearer: [] }]
      parameter name: :participant, in: :body, schema: {
        type: :object,
        properties: {
          verification_code: { type: :string },
          id: { type: :integer }
        },
        required: %w[verification_code id]
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

  path '/api/v1/participants/amend' do
    put('update participant attributes') do
      consumes 'application/json'
      produces 'application/json'
      security [{ bearer: [] }]
      parameter name: :participant, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string },
          phone_number: { type: :string },
          country: { type: :string },
          self_generated_id: { type: :string },
          name: { type: :string },
          rds_id: { type: :string },
          code: { type: :string },
          referrer_code: { type: :string },
          sgm_group: { type: :string },
          referrer_sgm_group: { type: :string },
          match: { type: :string },
          quota: { type: :string },
          preferred_contact_method: { type: :string }
        },
        required: ['email']
      }

      response(200, 'successful') do
        let(:email) { 'user@example.com' }

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

  path '/api/v1/participants/update_and_resend' do
    put('update participant attributes') do
      consumes 'application/json'
      produces 'application/json'
      security [{ bearer: [] }]
      parameter name: :participant, in: :body, schema: {
        type: :object,
        properties: {
          id: { type: :integer },
          contact: { type: :string },
          language: { type: :string }
        },
        required: %w[id contact language]
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

  path '/api/v1/participants/check' do
    post('check participant resume code') do
      consumes 'application/json'
      produces 'application/json'
      security [{ bearer: [] }]
      parameter name: :participant, in: :body, schema: {
        type: :object,
        properties: {
          resume_code: { type: :string }
        },
        required: ['resume_code']
      }

      response(200, 'successful') do
        let(:resume_code) { 'abcde' }

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

  path '/api/v1/participants/{id}' do
    # You'll want to customize the parameter types...
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show participant') do
      security [{ bearer: [] }]
      response(200, 'successful') do
        let(:id) { '123' }

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

    put('update participant') do
      consumes 'application/json'
      produces 'application/json'
      security [{ bearer: [] }]
      parameter name: :participant, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string },
          phone_number: { type: :string },
          country: { type: :string },
          self_generated_id: { type: :string },
          name: { type: :string },
          rds_id: { type: :string },
          code: { type: :string },
          referrer_code: { type: :string },
          sgm_group: { type: :string },
          referrer_sgm_group: { type: :string },
          match: { type: :string },
          quota: { type: :string },
          preferred_contact_method: { type: :string }
        },
        required: ['id']
      }

      response(200, 'successful') do
        let(:id) { '123' }

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

    delete('delete participant') do
      security [{ bearer: [] }]

      response(200, 'successful') do
        let(:id) { '123' }

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
