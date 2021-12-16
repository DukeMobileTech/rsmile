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
  before_save :modify_source
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

  def self.heard_from
    ['Not Indicated', 'Radio advertisement', 'TV advertisement',
     'Billboard / sign / poster / pamphlet / newspaper advertisement',
     'Social media advertisement', 'From a friend / family member / acquaintance',
     'From a local organization', 'Other', 'Social media post / discussion',
     'Newspaper article / magazine article / newsletter',
     'From a local organization or peer educator']
  end

  def modify_source
    unless source.blank?
      source_value = []
      source.split(',').each do |value|
        case value
        when '1'
          source_value << 'Radio advertisement'
        when '2'
          source_value << 'TV advertisement'
        when '3'
          source_value << 'Billboard / sign / poster / pamphlet / newspaper advertisement'
        when '4'
          source_value << 'Social media advertisement'
        when '5'
          source_value << 'From a friend / family member / acquaintance'
        when '6'
          source_value << 'From a local organization'
        when '7'
          source_value << 'Other'
        when '8'
          source_value << 'Social media post / discussion'
        when '9'
          source_value << 'Newspaper article / magazine article / newsletter'
        when '10'
          source_value << 'From a local organization or peer educator'
        end
      end
      self.source = source_value.join(',')
    end
  end

  def self.survey_sources(country_name)
    source_count = {}
    response_sources = []
    responses = SurveyResponse.where(country: country_name)
    sources = responses.map { |response| response.source }
    sources.each do |src|
      response_sources << if src.nil?
                            'Not Indicated'
                          else
                            src.split(',')
                          end
    end
    rs = response_sources.flatten
    heard_from.each do |hf|
      source_count[hf] = rs.count { |element| element == hf }
    end
    source_count
  end
end
