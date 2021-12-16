require 'administrate/base_dashboard'

class SurveyResponseDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    participant: Field::BelongsTo,
    id: Field::Number,
    survey_uuid: Field::String,
    survey_title: Field::String,
    response_uuid: Field::String,
    country: Field::String,
    survey_complete: Field::Boolean,
    eligible: Field::Boolean,
    consented: Field::Boolean,
    source: Field::String,
    language: Field::String,
    sgm_group: Field::String,
    created_at: Field::DateTime.with_options(format: '%Y-%m-%d %I:%M %p'),
    updated_at: Field::DateTime
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i[
    id
    survey_title
    response_uuid
    country
    eligible
    consented
    survey_complete
    source
    language
    sgm_group
    created_at
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
    participant
    id
    survey_uuid
    survey_title
    response_uuid
    survey_complete
    country
    eligible
    consented
    source
    language
    sgm_group
    created_at
    updated_at
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
    participant
    survey_uuid
    survey_title
    response_uuid
    survey_complete
    country
    eligible
    consented
    source
    language
    sgm_group
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

  # Overwrite this method to customize how survey responses are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(survey_response)
  #   "SurveyResponse ##{survey_response.id}"
  # end
end
