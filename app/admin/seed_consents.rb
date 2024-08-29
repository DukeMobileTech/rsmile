ActiveAdmin.register SurveyResponse, as: 'Seed Consent' do
  menu priority: 4

  controller do
    def scoped_collection
      SurveyResponse.seed_consents
    end
  end
end
