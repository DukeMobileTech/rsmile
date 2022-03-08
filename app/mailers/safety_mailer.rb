class SafetyMailer < ApplicationMailer
  def safety_planning_form
    @language = params[:language]
    filename = params[:filename]
    email = params[:email]
    title = I18n.t('safety.email_title', locale: @language)
    attachments["#{title}.pdf"] = File.read(filename)
    mail(to: email, subject: title)
  end
end
