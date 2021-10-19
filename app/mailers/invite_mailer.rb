class InviteMailer < ApplicationMailer

  def invite_email
    @invite = params[:invite]
    mail(to: @invite.email, :subject => "Welcome to SMILE Dashboard")
  end

end
