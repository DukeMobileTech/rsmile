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
  store_accessor :metadata, :source, :language, :sgm_group

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
end
