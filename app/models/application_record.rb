class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  ALL_SGM_GROUPS = ['non-binary person', 'transgender woman', 'transgender man',
                    'woman attracted to women', 'man attracted to men', 'multi-attracted woman',
                    'multi-attracted man', 'no group', 'ineligible', 'blank'].freeze
  INELIGIBLE_SGM_GROUPS = ['blank', 'ineligible', 'no group'].freeze
  ELIGIBLE_SGM_GROUPS = ALL_SGM_GROUPS - INELIGIBLE_SGM_GROUPS
  COUNTRIES = %w[Brazil Kenya Vietnam].freeze
  COLORS = %w[9C6ACB 6DD865 85B2C9 559F93].freeze
  SGM_CODES = {
    'non-binary person' => 'NBP',
    'transgender woman' => 'TW',
    'transgender man' => 'TM',
    'woman attracted to women' => 'WAW',
    'man attracted to men' => 'MAM',
    'multi-attracted woman' => 'MUAW',
    'multi-attracted man' => 'MUAM',
    'no group' => 'NG',
    'ineligible' => 'IN',
    'blank' => 'BL'
  }.freeze
  SGM_GROUPS_PLURAL = {
    'non-binary person' => 'non-binary people',
    'transgender woman' => 'transgender women',
    'transgender man' => 'transgender men',
    'woman attracted to women' => 'women attracted to women',
    'man attracted to men' => 'men attracted to men',
    'multi-attracted woman' => 'multi-attracted women',
    'multi-attracted man' => 'multi-attracted men'
  }.freeze
  SOURCES = {
    '0' => 'Not indicated',
    '1' => 'Radio advertisement',
    '2' => 'TV advertisement',
    '3' => 'Podcast',
    '4' => 'Billboard / sign / poster / pamphlet / newspaper advertisement',
    '5' => 'Newspaper article / magazine article / newsletter',
    '6' => 'Social media advertisement',
    '7' => 'Social media post / discussion',
    '8' => 'Friend / family member / acquaintance',
    '9' => 'Local organization',
    '10' => 'Local organization or peer educator',
    '11' => 'Other',
    '12' => 'VTC Team CBO',
    '13' => 'FTM Vietnam Organization',
    '14' => 'CSAGA',
    '15' => 'BE+ Clun in University of Social Sciences and Humanities (HCMUSSH)',
    '16' => 'Event Club in Van Lang University',
    '17' => 'Club in Can Tho University',
    '18' => 'RMIT University Vietnam',
    '19' => 'YKAP Vietnam',
    '20' => 'Song Tre Son La',
    '21' => 'The Leader House An Giang',
    '22' => 'Vuot Music Video',
    '23' => 'Motive Agency',
    '24' => 'Social work Club from University of Labour and Social Affairs 2',
    '25' => 'Influencers',
    '26' => 'Instagram'
  }.freeze
  INITIAL = 'SEEDS INVITE'.freeze
  REMIND = 'SEEDS INVITE REMINDER'.freeze
  FIRST = 'POST CONSENT'.freeze
  SECOND = 'POST CONSENT REMINDER'.freeze
  THIRD = 'PAYMENT'.freeze
  FOURTH = 'GRATITUDE'.freeze
  REMINDER_TYPES = [INITIAL, REMIND, FIRST, SECOND, THIRD, FOURTH].freeze

  if Rails.env.production?
    REMINDERS = {
      one: 1.day,
      two: 2.days,
      three: 3.days
    }.freeze
  end

  if Rails.env.development? || Rails.env.test?
    REMINDERS = {
      one: 1.minute,
      two: 2.minutes,
      three: 3.minutes
    }.freeze
  end
end
