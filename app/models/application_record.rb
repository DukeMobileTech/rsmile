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
    'en' => {
      'non-binary person' => 'non-binary people',
      'transgender woman' => 'transgender women',
      'transgender man' => 'transgender men',
      'woman attracted to women' => 'lesbian women',
      'man attracted to men' => 'gay men',
      'multi-attracted woman' => 'bisexual / pansexual women',
      'multi-attracted man' => 'bisexual / pansexual men'
    },
    'pt-br' => {
      'non-binary person' => 'indivíduos não-binário',
      'transgender woman' => 'mulheres transgenero',
      'transgender man' => 'homens transgenero',
      'woman attracted to women' => 'mulheres lésbicas',
      'man attracted to men' => 'homens gays',
      'multi-attracted woman' => 'mulheres bisexuais / pansexuais',
      'multi-attracted man' => 'homens bisexuais / pansexuais'
    },
    'sw' => {
      'non-binary person' => 'watu wasiojitambulisha na jinsia ya kike au kiume',
      'transgender woman' => 'wanawake wanaohisi walizaliwa na jinsia ya kiume',
      'transgender man' => 'wanaume waliozaliwa na jinsia ya kike',
      'woman attracted to women' => 'wanawake wasagaji',
      'man attracted to men' => 'wanaume mashoga',
      'multi-attracted woman' => 'wanawake wanaovutiwa na jinsia zaidi ya moja',
      'multi-attracted man' => 'wanaume wanaovutiwa na jinsia zaidi ya moja'
    },
    'vi' => {
      'non-binary person' => 'người phi nhị giới',
      'transgender woman' => 'chuyển giới nữ',
      'transgender man' => 'chuyển giới nam',
      'woman attracted to women' => 'đồng tính nữ',
      'man attracted to men' => 'đồng tính nam',
      'multi-attracted woman' => 'phụ nữ bị thu hút bởi cả nam lẫn nữ',
      'multi-attracted man' => 'đàn ông bị thu hút bởi cả nam lẫn nữ'
    }
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
      one: 2.days,
      two: 4.days,
      three: 6.days
    }.freeze
  end

  if Rails.env.development? || Rails.env.test?
    REMINDERS = {
      one: 1.minute,
      two: 5.minutes,
      three: 10.minutes
    }.freeze
  end

  SGM_GROUP_RECRUITMENT = {
    'Brazil' => {
      'non-binary person' => true,
      'transgender woman' => true,
      'transgender man' => true,
      'woman attracted to women' => true,
      'man attracted to men' => true,
      'multi-attracted woman' => true,
      'multi-attracted man' => true,
      'no group' => false,
      'ineligible' => false,
      'blank' => false
    },
    'Kenya' => {
      'non-binary person' => true,
      'transgender woman' => true,
      'transgender man' => true,
      'woman attracted to women' => true,
      'man attracted to men' => true,
      'multi-attracted woman' => true,
      'multi-attracted man' => true,
      'no group' => false,
      'ineligible' => false,
      'blank' => false
    },
    'Vietnam' => {
      'non-binary person' => true,
      'transgender woman' => true,
      'transgender man' => true,
      'woman attracted to women' => true,
      'man attracted to men' => true,
      'multi-attracted woman' => true,
      'multi-attracted man' => true,
      'no group' => false,
      'ineligible' => false,
      'blank' => false
    }
  }.freeze

  BASELINE_TITLE = 'SMILE Survey - Baseline RDS'.freeze
  SEEDS_CONSENT_TITLE = 'SMILE Consent - RDS Seeds'.freeze
  CONSENT_TITLE = 'SMILE Consent - RDS'.freeze
  CONTACT_TITLE = 'SMILE Contact Info Form - Baseline RDS'.freeze
  RECRUITMENT_TITLE = 'SMILE Recruitment - RDS'.freeze
end
