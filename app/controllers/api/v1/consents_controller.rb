class Api::V1::ConsentsController < Api::ApiController

  def create
    begin
      ConsentMailer.with(email: params[:email], language: params[:language]&.downcase).consent_form.deliver_now
      render json: { email: "sent" }, status: :ok
    rescue Exception
      render json: { email: "failed" }, status: :unprocessable_entity
    end
  end

end
