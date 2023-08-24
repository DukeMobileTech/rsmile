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
end
