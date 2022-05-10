ActiveAdmin.register SurveyResponse do
  menu priority: 5
  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :participant_id, :survey_uuid, :response_uuid, :survey_complete, :survey_title, :country, :eligible, :consented, :metadata
  #
  # or
  #
  # permit_params do
  #   permitted = [:participant_id, :survey_uuid, :response_uuid, :survey_complete, :survey_title, :country, :eligible, :consented, :metadata]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
end
