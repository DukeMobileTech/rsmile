class Api::V1::ConsentsController < Api::ApiController
  def create
    ConsentMailer.with(email: params[:email],
                       language: params[:language]&.downcase,
                       country: params[:country][0, 2]&.downcase,
                       seed: params[:seed]).consent_form.deliver_now
    render json: { email: 'sent' }, status: :ok
  rescue Exception
    render json: { email: 'failed' }, status: :unprocessable_entity
  end
end
