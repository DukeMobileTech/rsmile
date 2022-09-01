# ActiveAdmin.register SurveyResponse, as: 'Contact' do
#   menu label: 'Contact Form Surveys'
#   menu priority: 3
#   config.per_page = [25, 50, 100]
#   preserve_default_filters!
#   filter :participant, collection: -> { Participant.where(id: SurveyResponse.contacts.pluck(:participant_id).uniq) }
#   remove_filter :survey_uuid
#   remove_filter :survey_title
#
#   index do
#     column :id
#     column :response_uuid
#     column :participant
#     column :country
#     column :survey_complete
#     column :eligible
#     column :created_at
#     actions
#   end
#
#   controller do
#     def scoped_collection
#       SurveyResponse.contacts
#     end
#   end
# end
