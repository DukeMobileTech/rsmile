ActiveAdmin.register SurveyResponse, as: 'Consent' do
  menu label: 'Consent Surveys'
  menu priority: 2
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
