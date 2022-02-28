class ConsentMailer < ApplicationMailer
  def consent_form
    @language = params[:language]
    attachments['consent.pdf'] = File.read("#{Rails.root}/storage/consent/#{@language}.pdf")
    mail(to: params[:email], subject: I18n.t('form', locale: @language))
  end
end
