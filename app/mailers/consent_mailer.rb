class ConsentMailer < ApplicationMailer

  def consent_form
    attachments['consent.pdf'] = File.read("#{Rails.root}/storage/consent/#{params[:language]}.pdf")
    mail(to: params[:email], subject: 'SMILE Study Consent Form')
  end

end
