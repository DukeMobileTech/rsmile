require "administrate/base_dashboard"

class ParticipantDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    survey_responses: Field::HasMany,
    id: Field::Number,
    email: Field::String,
    phone_number: Field::String,
    country: Field::String,
    self_generated_id: Field::String,
    study_id: Field::String,
    rds_id: Field::String,
    code: Field::String,
    referrer_code: Field::String,
    sgm_group: Field::String,
    referrer_sgm_group: Field::String,
    match: Field::Boolean,
    quota: Field::Number,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    preferred_contact_method: Field::String,
    verified: Field::Boolean
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i[
    id
    email
    phone_number
    country
    verified
    self_generated_id
    study_id
    survey_responses
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
    survey_responses
    id
    email
    phone_number
    country
    self_generated_id
    study_id
    rds_id
    code
    referrer_code
    sgm_group
    referrer_sgm_group
    match
    quota
    preferred_contact_method
    verified
    created_at
    updated_at
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
    survey_responses
    email
    phone_number
    country
    self_generated_id
    study_id
    rds_id
    code
    referrer_code
    sgm_group
    referrer_sgm_group
    match
    quota
    preferred_contact_method
    verified
  ].freeze

  # COLLECTION_FILTERS
  # a hash that defines filters that can be used while searching via the search
  # field of the dashboard.
  #
  # For example to add an option to search for open resources by typing "open:"
  # in the search field:
  #
  #   COLLECTION_FILTERS = {
  #     open: ->(resources) { resources.where(open: true) }
  #   }.freeze
  COLLECTION_FILTERS = {}.freeze

  # Overwrite this method to customize how participants are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(participant)
  #   "Participant ##{participant.id}"
  # end
end
