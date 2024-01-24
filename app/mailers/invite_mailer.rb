class InviteMailer < ApplicationMailer
  def invite_email
    @invite = params[:invite]
    mail(to: @invite.email, subject: 'Welcome to SMILE RDS Dashboard')
  end
end
