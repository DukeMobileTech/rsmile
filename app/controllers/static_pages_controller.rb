class StaticPagesController < ApplicationController
  skip_before_action :require_login
  def glossary
    render 'static_pages/glossary', layout: false
  end

  def consent
    consent_filename = File.join(Rails.root, 'storage/consent/consent.pdf')
    send_file(consent_filename, filename: 'SGM-Pilot-Consent.pdf', disposition: 'inline', type: 'application/pdf')
  end
end
