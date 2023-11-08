require 'sorted_set'

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
#  duplicate       :boolean          default(FALSE)
#
class SurveyResponse < ApplicationRecord
  belongs_to :participant, optional: true, inverse_of: :survey_responses
  validates :response_uuid, presence: true, uniqueness: true

  before_save { self.country = ActionView::Base.full_sanitizer.sanitize country }
  before_save { self.sgm_group = sgm_group&.downcase }
  after_create { SurveyMetadataJob.set(wait: 15.days).perform_later(id) if baseline_survey? }
  after_save :assign_participant_sgm_group
  # after_save :fetch_metadata

  store_accessor :metadata, :source, :language, :sgm_group, :ip_address, :duration,
                 :birth_year, :age, :progress, :race, :ethnicity, :gender, :referee_code,
                 :gender_identity, :sexual_orientation, :intersex, :can_contact,
                 :sexual_attraction, :attraction_eligibility, :attraction_sgm_group,
                 :main_block, :group_a, :group_b, :group_c, :groups_done, :survey_counter,
                 :self_generated_id, :mobilizer_code, :locality, :city, :region, :sgm_network_size,
                 :education

  scope :consents, -> { where(survey_title: 'SMILE Consent') }
  scope :contacts, -> { where(survey_title: 'SMILE Contact Info Form - Baseline') }
  scope :baselines, -> { where(survey_title: 'SMILE Survey - Baseline') }
  scope :safety_plans, -> { where(survey_title: 'Safety Planning') }
  # An included baseline survey is one that is:
  # 1. Not a duplicate
  # 2. Belongs to a participant who is not excluded
  scope :included_baselines, lambda {
    baselines.where(duplicate: false)
             .where.not(participant_id: Participant.excluded.pluck(:id))
  }
  scope :completed_sogi_block, lambda {
    included_baselines.where('(metadata -> :key) NOT IN (:values)', key: 'sgm_group', values: ['blank'])
  }
  scope :completed_main_block, lambda {
    included_baselines.where('metadata @> hstore(:key, :value)', key: 'main_block', value: 'true')
  }
  scope :completed_group_a, lambda {
    included_baselines.where('metadata @> hstore(:key, :value)', key: 'group_a', value: 'true')
  }
  scope :completed_group_b, lambda {
    included_baselines.where('metadata @> hstore(:key, :value)', key: 'group_b', value: 'true')
  }
  scope :completed_group_c, lambda {
    included_baselines.where('metadata @> hstore(:key, :value)', key: 'group_c', value: 'true')
  }
  scope :duplicate_baselines, -> { baselines.where(duplicate: true) }
  scope :excluded_baselines, -> { baselines.where(participant_id: Participant.excluded.select(:id)) }
  # An eligible baseline survey is one that is:
  # 1. Not a duplicate
  # 2. Belongs to a participant who is not excluded
  # 3. Belongs to a participant who is not in an ineligible SGM group
  scope :eligible_baselines, lambda {
    included_baselines.where('(metadata -> :key) NOT IN (:values)', key: 'sgm_group', values: INELIGIBLE_SGM_GROUPS)
  }
  # An eligible baseline survey is one that is:
  # 1. Not a duplicate
  # 2. Belongs to a participant who:
  #   1. is not excluded
  #   2. is in an ineligible SGM group
  #   3. is in an eligible attraction SGM group
  scope :attraction_eligible_baselines, lambda {
    included_baselines.where('(metadata -> :key) IN (:values)', key: 'sgm_group', values: INELIGIBLE_SGM_GROUPS)
                      .where('metadata @> hstore(:key, :value)', key: 'attraction_eligibility', value: 'eligible')
  }
  scope :ineligible_baselines, lambda {
    included_baselines.where('(metadata -> :key) IN (:values)', key: 'sgm_group', values: INELIGIBLE_SGM_GROUPS)
  }
  scope :eligible_completed_main_block, lambda {
    completed_main_block.where('(metadata -> :key) NOT IN (:values)', key: 'sgm_group', values: INELIGIBLE_SGM_GROUPS)
  }

  def baseline_survey?
    survey_title&.strip == 'SMILE Survey - Baseline'
  end

  def short_survey?
    survey_uuid == Rails.application.credentials.config[:SHORT_SURVEY_ID]
  end

  def long_survey?
    survey_uuid == Rails.application.credentials.config[:LONG_SURVEY_ID]
  end

  def source_label
    names = []
    source&.split(',')&.each do |s|
      names << SOURCES[s.strip]
    end
    names.join(' | ')
  end

  def country
    (read_attribute(:country).presence || participant&.country)
  end

  def country=(str)
    str = participant.country if str.blank? && participant
    write_attribute(:country, str)
  end

  def email
    participant&.email
  end

  def phone_number
    participant&.phone_number
  end

  def participant_self_gen_id
    participant&.self_generated_id
  end

  def set_attraction_sgm_group
    if attraction_eligible?
      attractions = sexual_attraction&.split(',')
      if attractions.blank?
        self.attraction_sgm_group = 'blank'
      elsif attractions.size == 1
        attr_val = attractions.first.strip
        case gender_identity
        when '1', '10'
          self.attraction_sgm_group = female_attraction_grouping(attr_val)
        when '2', '11'
          self.attraction_sgm_group = male_attraction_grouping(attr_val)
        end
      elsif attractions.size > 1
        attraction_grouping_2(attractions)
      end
    else
      self.attraction_sgm_group = nil
    end
    save
  end

  def female_attraction_grouping(value)
    case value
    when '1'
      'woman attracted to women'
    when '2', '4', '5', '6'
      'multi-attracted woman'
    when '3'
      'ineligible'
    when '8'
      'asexual'
    when '7', '88'
      'no group'
    end
  end

  def male_attraction_grouping(value)
    case value
    when '1'
      'ineligible'
    when '2', '4', '5', '6'
      'multi-attracted man'
    when '3'
      'man attracted to men'
    when '8'
      'asexual'
    when '7', '88'
      'no group'
    end
  end

  def attraction_grouping_2(attractions)
    case gender_identity
    when '1', '10'
      if attractions.size == 2 && attractions.include?('3') && attractions.include?('4')
        self.attraction_sgm_group = 'ineligible'
      elsif attractions.any? { |a| %w[1 2].include?(a.strip) } && attractions.any? { |a| %w[3 4 5 6 7].include?(a.strip) }
        self.attraction_sgm_group = 'multi-attracted woman'
      end
    when '2', '11'
      if attractions.size == 2 && attractions.include?('1') && attractions.include?('2')
        self.attraction_sgm_group = 'ineligible'
      elsif attractions.any? { |a| %w[3 4].include?(a.strip) } && attractions.any? { |a| %w[1 2 5 6 7].include?(a.strip) }
        self.attraction_sgm_group = 'multi-attracted man'
      end
    end
  end

  def attraction_eligible?
    attraction_eligibility == 'eligible' && INELIGIBLE_SGM_GROUPS.include?(sgm_group)
  end

  def attraction_ineligible?
    attraction_eligibility == 'ineligible' && INELIGIBLE_SGM_GROUPS.exclude?(sgm_group)
  end

  def mobilizer_quota_exceeded?
    false
  end

  def sgm_group_mismatch?
    attraction_eligible? || attraction_ineligible?
  end

  def mismatch_class
    if attraction_eligible?
      'mismatch'
    else
      'mismatch-reverse'
    end
  end

  def set_attraction_eligibility
    self.attraction_eligibility = 'ineligible'
    attractions = sexual_attraction&.split(',')
    case gender_identity
    when '1', '10'
      self.attraction_eligibility = 'eligible' if attractions&.any? { |a| %w[1 2 4 5 6 7 8].include?(a) }
    when '2', '11'
      self.attraction_eligibility = 'eligible' if attractions&.any? { |a| %w[2 3 4 5 6 7 8].include?(a) }
    when '4', '12', '5', '13', '6', '14'
      self.attraction_eligibility = 'eligible'
    end
  end

  def gender_identity_label
    case gender_identity
    when '1', '10'
      'Woman'
    when '2', '11'
      'Man'
    when '3'
      'Agender'
    when '4', '12'
      'Non-binary Person'
    when '5', '13'
      'Transgender Woman'
    when '6', '14'
      'Transgender Man'
    when '8'
      'Questioning Person'
    when '9'
      'Another Gender'
    else
      gender_identity
    end
  end

  def sexual_orientation_label
    case sexual_orientation
    when '1', '9', '16'
      'Lesbian / Gay'
    when '3', '10', '17'
      'Bisexual / Pansexual'
    when '4', '11'
      'Queer'
    when '5', '12'
      'Questioning'
    when '6', '13', '18'
      'Asexual'
    when '7', '14', '19'
      'Heterosexual / Straight'
    when '8', '15'
      'Another Sexual Orientation'
    when '20'
      'Decline to answer'
    else
      sexual_orientation
    end
  end

  def sexual_attraction_label
    sexual_attraction&.split(',')&.map { |v| sexual_attraction_value(v) }&.join(', ')
  end

  def sexual_attraction_value(value)
    case value
    when '1'
      'Women'
    when '2'
      'Transgender women'
    when '3'
      'Men'
    when '4'
      'Transgender men'
    when '5'
      'Non-binary individuals assigned female sex at birth'
    when '6'
      'Non-binary individuals assigned male sex at birth'
    when '7'
      'Another gender'
    when '8'
      'Not attracted to any gender'
    when '88'
      "Don't know"
    else
      value
    end
  end

  def fetch_qualtrics_data
    url = URI("https://#{Rails.application.credentials.config[:QUALTRICS_BASE_URL]}/surveys/#{survey_uuid}/responses/#{response_uuid}")
    http = create_http(url)
    request = create_get_request(url)
    response = http.request(request)
    return if response.code != '200'

    parse_response(response)
  end

  def parse_response(response)
    json_body = JSON.parse(response.body.force_encoding('ISO-8859-1').encode('UTF-8'))
    set_metadata(json_body['result']['values'], json_body['result']['labels'])
    set_attraction_eligibility
    save
    set_attraction_sgm_group
  end

  def set_metadata(values, labels)
    response_progress(values)
    update_age(labels)
    parse_gender(labels)
    update_location(values)
    recruitment(values)
    parse_race_ethnicity(self[:country], values)
    contactable(values)
    update_sogi(values, labels)
    group_completion(values)
    demographics(values)
  end

  def response_progress(values)
    assign_attributes(progress: values['progress'].to_s, duration: values['duration'].to_s,
                      ip_address: values['ipAddress'], survey_counter: values['Survey_Counter'],
                      survey_complete: values['finished'])
  end

  def update_age(labels)
    self.age = labels['QID471'] if age.blank? && labels['QID471'].present?
  end

  def update_location(values)
    assign_attributes(country: self[:country].presence || values['Country'],
                      self_generated_id: values['SELF_GENERATED_ID'],
                      source: values['QID446']&.join(','))
    set_community(values)
    update_city(values)
    update_region(values)
  end

  def set_community(values)
    locality = values['QID5'] if values['QID5'].present?
    locality = values['QID503'] if values['QID503'].present?
    locality = values['QID541'] if values['QID541'].present?

    if locality == 1
      self.locality = 'rural'
    elsif locality == 2
      self.locality = 'urban'
    elsif locality == 89
      self.locality = 'suburban'
    elsif locality == 88
      self.locality = 'not sure'
    end
  end

  def update_city(values)
    return if values['QID2'].blank?

    self.city = CITIES[values['QID2']]
  end

  def update_region(values)
    return if values['QID12'].blank?

    self.region = REGIONS[values['QID12']]
  end

  def demographics(values)
    return if values['QID46'].blank?

    self.education = EDUCATION_LEVELS[values['QID46']]
  end

  def recruitment(values)
    self.referee_code = values['QID556_1_TEXT']&.downcase&.strip
    self.mobilizer_code = values['QID556_1_TEXT']&.downcase&.strip if mobilizer_code.blank?
  end

  def update_sogi(values, labels)
    assign_attributes(gender_identity: values['Gender_Identity'],
                      sexual_orientation: values['Sexual_Orientation'],
                      sexual_attraction: values['QID35']&.sort&.join(','),
                      sgm_group: values['SGM_Group'].present? ? values['SGM_Group']&.downcase : 'blank',
                      intersex: labels['QID19'], sgm_network_size: values['QID422_TEXT'])
  end

  def update_block_completion(values)
    assign_attributes(main_block: values['QID549'].present?, group_a: group_a_complete?(values),
                      group_b: group_b_complete?(values), group_c: group_c_complete?(values))
  end

  def update_long_completion
    assign_attributes(main_block: survey_complete, group_a: survey_complete,
                      group_b: survey_complete, group_c: survey_complete)
  end

  def group_a_complete?(values)
    values['QID548'].present? || values['QID553'].present? || values['QID272'].present?
  end

  def group_b_complete?(values)
    values['QID551'].present? || values['QID547'].present? || values['QID150'].present?
  end

  def group_c_complete?(values)
    values['QID552'].present? || values['QID554'].present? || values['QID143'].present?
  end

  def group_completion(values)
    update_block_completion(values) if short_survey?
    update_long_completion if long_survey?
    assign_attributes(groups_done: [group_a, group_b, group_c].count(true))
  end

  def contactable(values)
    self.can_contact = (values['QID407'].present? && values['QID407'] == 1) ||
                       (values['QID557'].present? && values['QID557'] == 1) ||
                       (values['QID540'].present? && values['QID540'] == 1)
  end

  def parse_gender(labels)
    qid21 = labels['QID21']
    qid21 = qid21.split('(').first.strip if qid21.present? && qid21.include?('(')
    qid21 = labels['QID20']&.join('|') if qid21.blank?
    self.gender = assign_gender(qid21&.downcase)
  end

  def assign_gender(qid21)
    if qid21&.include?('transgender man')
      'Man'
    elsif qid21&.include?('transgender woman')
      'Woman'
    elsif qid21&.include?('non-binary person')
      'Unknown'
    end
  end

  def parse_race_ethnicity(kountry, values)
    case kountry
    when 'Kenya'
      assign_race_ethnicity('Black', values['QID538'])
    when 'Vietnam'
      assign_race_ethnicity('Asian', values['QID45'])
    when 'Brazil'
      assign_race_ethnicity(brazil_race(values['QID45']), values['QID45'])
    end
  end

  def assign_race_ethnicity(race, ethn_values)
    ethn_values = [] if ethn_values.blank?
    self.race = race
    self.ethnicity = ethn_values&.map { |val| ETHNICITIES[val.strip] }&.join(', ')
  end

  def ethnicity_label
    lookup = {
      'Kenya' => 'Not Hispanic or Latino',
      'Vietnam' => 'Not Hispanic or Latino',
      'Brazil' => 'Hispanic or Latino'
    }
    lookup[country]
  end

  # rubocop:disable Metrics/MethodLength, Metrics/CyclomaticComplexity
  def brazil_race(values)
    value = ETHNICITIES[values&.first&.strip]
    case value
    when 'Branco'
      'White'
    when 'Pardo'
      'More than one race'
    when 'Preto'
      'Black'
    when 'Amarelo'
      'Asian'
    when 'Indigenous'
      'American Indian'
    else
      'Unknown'
    end
  end
  # rubocop:enable Metrics/MethodLength, Metrics/CyclomaticComplexity

  def network_class
    octet = ip_address&.split('.')&.first&.to_i
    case octet
    when 1..127
      'A'
    when 128..191
      'B'
    when 192..223
      'C'
    end
  end

  def ip_network
    octets = ip_address&.split('.')
    case network_class
    when 'A'
      octets&.first
    when 'B'
      octets&.first(2)&.join('.')
    when 'C'
      octets&.first(3)&.join('.')
    end
  end

  def ip_host
    octets = ip_address&.split('.')
    case network_class
    when 'A'
      octets&.last(3)&.join('.')
    when 'B'
      octets&.last(2)&.join('.')
    when 'C'
      octets&.last
    end
  end

  private

  def assign_participant_sgm_group
    return if participant.blank? || !baseline_survey?

    participant.assign_sgm_group
  end

  def fetch_metadata
    return unless baseline_survey?

    SurveyMetadataJob.perform_later(id) if saved_change_to_survey_complete? && survey_complete
  end

  def create_http(url)
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    http
  end

  def create_get_request(url)
    request = Net::HTTP::Get.new(url)
    request['Content-Type'] = 'application/json'
    request['X-API-TOKEN'] = Rails.application.credentials.config[:QUALTRICS_TOKEN]
    request
  end
end
