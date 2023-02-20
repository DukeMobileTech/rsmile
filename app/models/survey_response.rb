# == Schema Information
#
# Table name: survey_responses
#
#  id              :bigint           not null, primary key
#  participant_id  :integer
#  survey_uuid     :string
#  response_uuid   :string
#  survey_complete :boolean
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  survey_title    :string
#  country         :string
#  eligible        :boolean          default(TRUE)
#  consented       :boolean          default(TRUE)
#  metadata        :hstore
#
class SurveyResponse < ApplicationRecord
  belongs_to :participant, optional: true
  validates :response_uuid, presence: true, uniqueness: true
  before_save { self.country = ActionView::Base.full_sanitizer.sanitize country }
  before_save { self.sgm_group = sgm_group&.downcase }
  store_accessor :metadata, :source, :language, :sgm_group, :ip_address, :duration, :birth_year, :age, :progress
  scope :consents, -> { where(survey_title: 'SMILE Consent') }
  scope :contacts, -> { where(survey_title: 'SMILE Contact Info Form - Baseline') }
  scope :baselines, -> { where(survey_title: 'SMILE Survey - Baseline') }
  scope :safety_plans, -> { where(survey_title: 'Safety Planning') }

  def source_label
    names = []
    source&.split(',')&.each do |s|
      names << SurveyResponse.named_source(s.strip)
    end
    names.join(' | ')
  end

  def country
    if read_attribute(:country).blank?
      participant&.country
    else
      read_attribute(:country)
    end
  end

  def country=(str)
    str = participant.country if str.blank? && participant
    write_attribute(:country, str)
  end

  def self.named_source(name)
    case name
    when '0'
      'Not Indicated'
    when '1'
      'Radio advertisement'
    when '2'
      'TV advertisement'
    when '3'
      'Podcast'
    when '4'
      'Billboard / sign / poster / pamphlet / newspaper advertisement'
    when '5'
      'Newspaper article / magazine article / newsletter'
    when '6'
      'Social media advertisement'
    when '7'
      'Social media post / discussion'
    when '8'
      'From a friend / family member / acquaintance'
    when '9'
      'From a local organization'
    when '10'
      'From a local organization or peer educator'
    when '11'
      'Other'
    end
  end

  def self.survey_sources(country_name)
    source_count = {}
    response_sources = []
    responses = SurveyResponse.where(country: country_name, survey_title: 'SMILE Survey - Baseline')
    sources = responses.map { |response| response.source }
    sources.each do |src|
      response_sources << if src.blank?
                            '0'
                          else
                            src.split(',')
                          end
    end
    rs = response_sources.flatten
    (0..11).each do |hf|
      next if hf == 9 && country_name == 'Vietnam'
      next if hf == 10 && country_name != 'Vietnam'

      source_count[named_source(hf.to_s)] = rs.count { |element| element.strip == hf.to_s }
    end
    source_count
  end

  def self.consent_stats(country_name)
    responses = SurveyResponse.where(country: country_name, survey_title: 'SMILE Consent')
    {
      'Consented': responses.count { |r| r.consented },
      'Not Consented': responses.count { |r| !r.consented }
    }
  end

  def self.baseline_stats(country_name)
    responses = SurveyResponse.where(country: country_name, survey_title: 'SMILE Survey - Baseline')
    completed = responses.where(survey_complete: true).pluck(:participant_id).uniq
    eligible_completed = responses.where(survey_complete: true, eligible: true).pluck(:participant_id).uniq
    partials = responses.where(survey_complete: false)
    {
      'Completed': completed.size,
      'Eligible Completed': eligible_completed.size,
      'Partials': partials.size
    }
  end

  def qualtrics_metadata
    url = URI("https://#{Rails.application.credentials.config[:QUALTRICS_BASE_URL]}/surveys/#{survey_uuid}/responses/#{response_uuid}")
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Get.new(url)
    request['Content-Type'] = 'application/json'
    request['X-API-TOKEN'] = Rails.application.credentials.config[:QUALTRICS_TOKEN]
    response = http.request(request)
    return if response.code != 200

    json_body = JSON.parse(response.read_body)
    save_metadata(json_body['result']['values'])
  end

  def save_metadata(values)
    self.progress = values['progress']
    self.duration = values['duration']
    self.ip_address = values['ipAddress']
    save
  end
end
