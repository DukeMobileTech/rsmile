ActiveAdmin.register SurveyResponse, as: 'Recruitment' do
  menu priority: 10

  controller do
    def scoped_collection
      SurveyResponse.recruitments
    end
  end
end
