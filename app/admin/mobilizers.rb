ActiveAdmin.register SurveyResponse, as: 'Mobilizer' do
  menu priority: 5
  config.per_page = [50, 100, 250, 500, 1000, 5000]
  actions :all, except: %i[new edit destroy]
  preserve_default_filters!
  filter :participant, collection: -> { Participant.where(id: SurveyResponse.baselines.pluck(:participant_id).uniq) }
  remove_filter :survey_title
  remove_filter :eligible
  remove_filter :consented
  remove_filter :country
  remove_filter :survey_uuid

  index row_class: ->(elem) { elem.mismatch_class if elem.mobilizer_quota_exceeded? } do
    column :id do |elem|
      link_to elem.id, admin_survey_response_path(elem)
    end
    column 'Response', :response_uuid
    column 'Mobilizer', :referee_code, sortable: "metadata->'referee_code'"
    column :participant, sortable: 'participant_id'
    column :duplicate
    column :self_generated_id, sortable: "metadata->'self_generated_id'"
    column :sgm_group, sortable: "metadata->'sgm_group'"
    column :progress, sortable: "metadata->'progress'"
    column :duration, sortable: "metadata->'duration'"
    column :ip_address, sortable: "metadata->'ip_address'"
    column 'Complete', :survey_complete
    column 'Main Block Done', :main_block
    column 'Extra Blocks Done', :groups_done
    column :source, &:source_label
    column :created_at
    column :updated_at
    actions
  end

  csv do
    column :survey_uuid
    column :email, &:email
    column :phone, &:phone_number
    column :self_generated_id
    column :country
    column :language
    column :id
    column :response_uuid
    column :referee_code
    column :survey_complete
    column :progress
    column :duration
    column :main_block
    column :groups_done
    column :gender_identity, &:gender_identity_label
    column :sexual_attraction, &:sexual_attraction_label
    column :attraction_eligibility
    column :sexual_orientation, &:sexual_orientation_label
    column :sgm_group
    column :attraction_sgm_group
    column :source, &:source_label
    column :ip_address
    column :created_at
    column :updated_at
  end

  controller do
    def scoped_collection
      SurveyResponse.baselines.where(country: 'Kenya')
                    .where('metadata ? :key', key: 'referee_code')
    end

    def csv_filename
      "Mobilizer-Surveys-#{Time.now.to_i}.csv"
    end
  end
end
