class ConsentMailer < ApplicationMailer
  def consent_form
    @language = params[:language]
    filename = @language
    filename = "#{@language}-#{params[:country]}" if @language == 'en' && %w[ke vi].include?(params[:country])
    filename = "#{filename}-seeds" if params[:seed]
    attachments['consent.pdf'] = File.read("#{Rails.root}/storage/consent/#{filename}.pdf")
    mail(to: params[:email], subject: I18n.t('form', locale: @language))
  end
end
