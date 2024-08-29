ActiveAdmin.register SurveyResponse, as: 'Consent' do
  menu priority: 4, label: 'Invitee Consents'
  config.per_page = [25, 50, 100]
  preserve_default_filters!
  filter :participant, collection: -> { Participant.where(id: SurveyResponse.consents.pluck(:participant_id).uniq) }
  remove_filter :survey_uuid
  remove_filter :survey_title

  index do
    column :id
    column :response_uuid
    column :participant
    column :country
    column :survey_complete
    column :consented
    column :eligible
    column :created_at
    actions
  end

  controller do
    def scoped_collection
      SurveyResponse.consents
    end
  end
end
