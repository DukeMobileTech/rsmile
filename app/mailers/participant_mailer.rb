class ParticipantMailer < ApplicationMailer

  def welcome_email
    @participant = params[:participant]
    mail(to: @participant.email, subject: 'SMILE Study Participation')
  end

end
