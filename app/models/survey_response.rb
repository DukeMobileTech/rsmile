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
  belongs_to :participant, optional: true
  validates :response_uuid, presence: true, uniqueness: true

  before_save { self.country = ActionView::Base.full_sanitizer.sanitize country }
  before_save { self.sgm_group = sgm_group&.downcase }
  after_create { SurveyMetadataJob.set(wait: 15.days).perform_later(id) if baseline_survey? }
  after_save :assign_participant_sgm_group

  store_accessor :metadata, :source, :language, :sgm_group, :ip_address, :duration,
                 :birth_year, :age, :progress, :race, :ethnicity, :gender,
                 :gender_identity, :sexual_orientation, :intersex,
                 :sexual_attraction, :attraction_eligibility, :attraction_sgm_group,
                 :short_survey, :group_a, :group_b, :group_c

  scope :consents, -> { where(survey_title: 'SMILE Consent') }
  scope :contacts, -> { where(survey_title: 'SMILE Contact Info Form - Baseline') }
  scope :baselines, -> { where(survey_title: 'SMILE Survey - Baseline') }
  scope :safety_plans, -> { where(survey_title: 'Safety Planning') }
  scope :short_surveys, -> { where(survey_uuid: Rails.application.credentials.config[:SHORT_SURVEY_ID]) }
  scope :started_short_survey, lambda {
    short_surveys.where(duplicate: false)
                 .where.not(participant_id: Participant.excluded.pluck(:id))
  }
  scope :completed_main_block, lambda {
    started_short_survey.where('metadata @> hstore(:key, :value)', key: 'short_survey', value: 'true')
  }
  scope :completed_group_a, lambda {
    started_short_survey.where('metadata @> hstore(:key, :value)', key: 'group_a', value: 'true')
  }
  scope :completed_group_b, lambda {
    started_short_survey.where('metadata @> hstore(:key, :value)', key: 'group_b', value: 'true')
  }
  scope :completed_group_c, lambda {
    started_short_survey.where('metadata @> hstore(:key, :value)', key: 'group_c', value: 'true')
  }

  def baseline_survey?
    survey_title&.strip == 'SMILE Survey - Baseline'
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

  def email
    participant&.email
  end

  def phone_number
    participant&.phone_number
  end

  def self_generated_id
    participant&.self_generated_id
  end

  def self.named_source(num)
    case num
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
    when '12'
      'From VTC Team CBO'
    when '13'
      'From FTM Vietnam Organization'
    when '14'
      'From CSAGA'
    when '15'
      'From BE+ Clun in University of Social Sciences and Humanities (HCMUSSH)'
    when '16'
      'From Event Club in Van Lang University'
    when '17'
      'From a Club in Can Tho University'
    when '18'
      'From RMIT University Vietnam'
    when '19'
      'From YKAP Vietnam'
    when '20'
      'From Song Tre Son La'
    when '21'
      'From The Leader House An Giang'
    when '22'
      'From Vuot Music Video'
    when '23'
      'From Motive Agency'
    when '24'
      'From Social work Club from University of Labour and Social Affairs 2'
    else
      num
    end
  end

  def set_attraction_sgm_group
    if attraction_eligible?
      attractions = sexual_attraction&.split(',')
      if attractions.blank?
        self.attraction_sgm_group = 'blank'
      elsif attractions.size == 1
        attr_val = attractions.first.strip
        case gender_identity
        when '1','10'
          self.attraction_sgm_group = female_attraction_grouping(attr_val)
        when '2','11'
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
    when '2','4','5','6'
      'multi-attracted woman'
    when '3'
      'ineligible'
    when '8'
      'asexual'
    when '7','88'
      'no group'
    end
  end

  def male_attraction_grouping(value)
    case value
    when '1'
      'ineligible'
    when '2','4','5','6'
      'multi-attracted man'
    when '3'
      'man attracted to men'
    when '8'
      'asexual'
    when '7','88'
      'no group'
    end
  end

  def attraction_grouping_2(attractions)
    case gender_identity
    when '1','10'
      if attractions.size == 2 && attractions.include?('3') && attractions.include?('4')
        self.attraction_sgm_group = 'ineligible'
      elsif attractions.any? { |a| %w[1 2].include?(a.strip) } && attractions.any? { |a| %w[3 4 5 6 7].include?(a.strip) }
        self.attraction_sgm_group = 'multi-attracted woman'
      end
    when '2','11'
      if attractions.size == 2 && attractions.include?('1') && attractions.include?('2')
        self.attraction_sgm_group = 'ineligible'
      elsif attractions.any? { |a| %w[3 4].include?(a.strip) } && attractions.any? { |a| %w[1 2 5 6 7].include?(a.strip) }
        self.attraction_sgm_group = 'multi-attracted man'
      end
    end
  end

  def attraction_eligible?
    attraction_eligibility == 'eligible' &&
      ['no group', 'ineligible', 'blank'].include?(sgm_group)
  end

  def attraction_ineligible?
    attraction_eligibility == 'ineligible' &&
      ['no group', 'ineligible', 'blank'].exclude?(sgm_group)
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
    when '1','10'
      self.attraction_eligibility = 'eligible' if attractions&.any? { |a| %w[1 2 4 5 6 7 8].include?(a) }
    when '2','11'
      self.attraction_eligibility = 'eligible' if attractions&.any? { |a| %w[2 3 4 5 6 7 8].include?(a) }
    when '4','12','5','13','6','14'
      self.attraction_eligibility = 'eligible'
    end
  end

  def gender_identity_label
    case gender_identity
    when '1','10'
      'Woman'
    when '2','11'
      'Man'
    when '3'
      'Agender'
    when '4','12'
      'Non-binary Person'
    when '5','13'
      'Transgender Woman'
    when '6','14'
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
    when '1','9','16'
      'Lesbian / Gay'
    when '3','10','17'
      'Bisexual / Pansexual'
    when '4','11'
      'Queer'
    when '5','12'
      'Questioning'
    when '6','13','18'
      'Asexual'
    when '7','14','19'
      'Heterosexual / Straight'
    when '8','15'
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

  def self.eligible_baselines(kountry)
    ids = Participant.eligible_participants.where(country: kountry).pluck(:id)
    SurveyResponse.where(participant_id: ids)
                  .where(survey_title: 'SMILE Survey - Baseline')
                  .where(survey_complete: true)
                  .where(duplicate: false)
  end

  def self.sources_timeline(kountry)
    Groupdate.week_start = :monday
    responses = eligible_baselines(kountry)
    sources = {}
    weeks = SortedSet.new
    25.times do |num|
      next if num == 3 && kountry != 'Brazil'
      next if num == 9 && kountry == 'Vietnam'
      next if kountry != 'Vietnam' && [10, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24].include?(num)

      responses_by_source = if num.zero?
                              responses.select { |r| r.source.blank? }
                                       .group_by_week(format: '%m/%d/%y') { |r| r.created_at }
                                       .to_h { |k, v| [k, v.count] }
                            else
                              responses.select { |r| r.source&.split(',')&.include?(num.to_s) }
                                       .group_by_week(format: '%m/%d/%y') { |r| r.created_at }
                                       .to_h { |k, v| [k, v.count] }
                            end
      weeklies = {}
      responses_by_source.each do |week, count|
        next unless count.positive?

        weeklies[week] = count
        weeks << Date.strptime(week, '%m/%d/%y')
      end
      sources[num] = weeklies
    end
    final_sources = {}
    sources.each do |source, weeklies|
      next if weeklies.blank?

      source_week_list = []
      weeks.each do |week|
        week_str = week.strftime('%m/%d/%y')
        source_week_list << if weeklies[week_str].nil?
                              { week_str => 0 }
                            else
                              { week_str => weeklies[week_str] }
                            end
      end
      final_sources[source] = source_week_list
    end
    final_sources
  end

  def self.ineligible_sgm_groups
    ['blank', 'ineligible', 'no group']
  end

  def self.survey_sources(country_name)
    source_count = {}
    cr = baselines.where(country: country_name)
    eligible = cr.where(survey_complete: true)
                 .where(duplicate: false)
                 .where('(metadata -> :key) NOT IN (:values)', key: 'sgm_group', values: ineligible_sgm_groups)
    ineligible = cr.where(survey_complete: false)
                   .or(cr.where(duplicate: true))
                   .or(cr.where('(metadata -> :key) IN (:values)', key: 'sgm_group', values: ineligible_sgm_groups))
    derived_eligible = []
    cr.each do |response|
      derived_eligible << response if response.attraction_eligible?
    end
    responses = []
    eligible.group_by(&:participant).each do |participant, part_resp|
      if participant.blank? || participant.include == false
        ineligible += part_resp
        next
      end
      responses << part_resp[0]
    end
    25.times do |hf|
      next if hf == 3 && country_name != 'Brazil'
      next if hf == 9 && country_name == 'Vietnam'
      next if country_name != 'Vietnam' && [10, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24].include?(hf)

      count1 = response_counts(hf, responses)
      count2 = response_counts(hf, ineligible)
      count3 = response_counts(hf, derived_eligible)
      source_count[hf.to_s] = { eligible: count1, ineligible: count2, derived: count3 } if (count1 + count2 + count3).positive?
    end
    source_count
  end

  def self.response_counts(num, responses)
    if num.zero?
      responses.select { |r| r.source.blank? }.size
    else
      responses.select { |r| r.source&.split(',')&.include?(num.to_s) }.size
    end
  end

  def self.consent_stats(country_name)
    responses = SurveyResponse.where(country: country_name, survey_title: 'SMILE Consent')
    {
      Consented: responses.count(&:consented),
      'Not Consented': responses.count { |r| !r.consented }
    }
  end

  def self.baseline_stats(country_name)
    responses = baselines.where(country: country_name)
    partials = responses.where(survey_complete: false)
    completed = responses.where(survey_complete: true)
    all_eligible = completed.where('(metadata -> :key) NOT IN (:values)', key: 'sgm_group', values: ineligible_sgm_groups)
    eligible = []
    duplicates = []
    excluded = []
    all_eligible.group_by(&:participant).each do |participant, part_resp|
      if participant.blank? || participant.include == false
        excluded += part_resp
        next
      end
      if part_resp.size == 1
        eligible += part_resp
      else
        eligible << part_resp[0]
        duplicates += part_resp[1..]
      end
    end
    ineligible = completed.where('(metadata -> :key) IN (:values)', key: 'sgm_group', values: ineligible_sgm_groups)
    derived = []
    ineligible.each do |response|
      derived << response if response.attraction_eligible?
    end

    {
      All: responses.size,
      Completed: completed.size,
      Partials: partials.size,
      Eligible: eligible.size,
      Ineligible: ineligible.size,
      Derived: derived.size,
      Duplicates: duplicates.size,
      Excluded: excluded.size
    }
  end

  def self.started_stats(country_name)
    started = started_short_survey.where(country: country_name)
    eligible_started = started.where('(metadata -> :key) NOT IN (:values)', key: 'sgm_group', values: ineligible_sgm_groups)
    [started.size, eligible_started.size]
  end

  def self.main_block_stats(country_name)
    main_block = completed_main_block.where(country: country_name)
    eligible_main_block = main_block.where('(metadata -> :key) NOT IN (:values)', key: 'sgm_group', values: ineligible_sgm_groups)
    [main_block.size, eligible_main_block.size]
  end

  def self.group_a_stats(country_name)
    group_a = completed_group_a.where(country: country_name)
    eligible_group_a = group_a.where('(metadata -> :key) NOT IN (:values)', key: 'sgm_group', values: ineligible_sgm_groups)
    [group_a.size, eligible_group_a.size]
  end

  def self.group_b_stats(country_name)
    group_b = completed_group_b.where(country: country_name)
    eligible_group_b = group_b.where('(metadata -> :key) NOT IN (:values)', key: 'sgm_group', values: ineligible_sgm_groups)
    [group_b.size, eligible_group_b.size]
  end

  def self.group_c_stats(country_name)
    group_c = completed_group_c.where(country: country_name)
    eligible_group_c = group_c.where('(metadata -> :key) NOT IN (:values)', key: 'sgm_group', values: ineligible_sgm_groups)
    [group_c.size, eligible_group_c.size]
  end

  def self.progress_stats(country_name)
    {
      'Started Short Survey': started_stats(country_name),
      'Completed Main Block': main_block_stats(country_name),
      'Completed Group A': group_a_stats(country_name),
      'Completed Group B': group_b_stats(country_name),
      'Completed Group C': group_c_stats(country_name)
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
    return if response.code != '200'

    json_body = JSON.parse(response.body.force_encoding('ISO-8859-1').encode('UTF-8'))
    set_metadata(json_body['result']['values'], json_body['result']['labels'])
    set_attraction_eligibility
    save
    set_attraction_sgm_group
  end

  def set_metadata(values, labels)
    self.progress = values['progress'].to_s
    self.duration = values['duration'].to_s
    self.ip_address = values['ipAddress']
    qid471 = labels['QID471']
    self.age = qid471 if age.blank? && qid471.present?
    parse_gender(labels)
    kountry = self[:country]
    kountry = values['Country'] if kountry.blank?
    self.country = kountry
    parse_race_ethnicity(kountry, values)
    qid19 = labels['QID19']
    self.intersex = qid19 if qid19.present?
    if self[:sgm_group].blank?
      self.sgm_group = values['SGM_Group'].present? ? values['SGM_Group']&.downcase : 'blank'
    end
    self.gender_identity = values['Gender_Identity']
    self.sexual_orientation = values['Sexual_Orientation']
    self.sexual_attraction = values['QID35']&.sort&.join(',') if values['QID35'].present?
    update_block_completion(values)
  end

  def update_block_completion(values)
    assign_attributes(short_survey: values['QID549'].present?,
                      group_a: values['QID548'].present? || values['QID553'].present?,
                      group_b: values['QID551'].present? || values['QID547'].present?,
                      group_c: values['QID552'].present? || values['QID554'].present?)
  end

  def parse_gender(labels)
    qid21 = labels['QID21']
    qid21 = qid21.split('(').first.strip if qid21.present? && qid21.include?('(')
    qid21 = labels['QID20']&.join('|') if qid21.blank?
    qid21 = 'Man' if qid21&.downcase&.include?('transgender man')
    qid21 = 'Woman' if qid21&.downcase&.include?('transgender woman')
    qid21 = 'Unknown' if qid21&.downcase&.include?('non-binary person')
    self.gender = qid21
  end

  def parse_race_ethnicity(kountry, values)
    case kountry
    when 'Kenya'
      self.race = 'Black'
      self.ethnicity = 'Not Hispanic or Latino'
    when 'Vietnam'
      self.race = 'Asian'
      self.ethnicity = 'Not Hispanic or Latino'
    when 'Brazil'
      self.race = brazil_race(values['QID45'])
      self.ethnicity = 'Hispanic or Latino'
    end
  end

  def brazil_race(value)
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
end
