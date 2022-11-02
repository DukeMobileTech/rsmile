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
  before_save { self.sgm_group = sgm_group&.downcase }
  after_save :enter_raffle
  after_save :update_raffle_quota
  store_accessor :metadata, :source, :language, :sgm_group, :ip_address, :duration, :birth_year, :age
  has_many :raffles, foreign_key: :response_uuid, primary_key: :response_uuid, dependent: :destroy

  def recruitment_survey?
    survey_title&.strip == 'SGM Pilot Recruitment & Lottery Info'
  end

  def pilot_survey?
    survey_title&.strip == 'SGM Pilot'
  end

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
    12.times do |hf|
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

  private

  def enter_raffle
    return unless recruitment_survey?
    return unless participant&.enter_raffle

    own = participant.raffles.where(completion_entry: true)
    return unless own.empty?

    pilot = participant.pilots.last
    return if pilot.nil?
    return unless pilot.survey_complete

    participant.raffles.create(completion_entry: true, recruitment_entry: false,
                               response_uuid: pilot&.response_uuid)
  end

  def update_raffle_quota
    return unless pilot_survey?
    return unless survey_complete

    recruiter = participant.recruiter
    return if recruiter.nil?
    return unless recruiter.enter_raffle
    return if recruiter.raffle_quota_met

    raffle_entry = recruiter.raffles.where(completion_entry: false, recruitment_entry: true,
                                           recruitee_code: participant.code)
    return unless raffle_entry.empty?

    Raffle.create(participant_id: recruiter.id, completion_entry: false, recruitment_entry: true,
                  recruitee_code: participant.code, response_uuid: response_uuid)
    quota = recruiter.raffles.count
    return unless quota >= 6

    recruiter.raffle_quota_met = true
    recruiter.save
  end
end
