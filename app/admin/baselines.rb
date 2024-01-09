# rubocop:disable Metrics/BlockLength
ActiveAdmin.register SurveyResponse, as: 'Baseline' do
  menu label: 'Baseline Surveys'
  menu priority: 4
  config.per_page = [50, 100, 250, 500, 1000, 2500, 5000, 10_000]
  permit_params :response_uuid, :participant_id, :country, :survey_complete, :eligible, :sgm_group, :source, :language, :duplicate
  preserve_default_filters!
  filter :participant, collection: -> { Participant.where(id: SurveyResponse.baselines.pluck(:participant_id).uniq) }
  remove_filter :survey_title
  remove_filter :eligible
  remove_filter :consented

  index row_class: ->(elem) { elem.mismatch_class if elem.sgm_group_mismatch? } do
    column :id
    column 'Response', :response_uuid
    column :participant, sortable: 'participant_id'
    column :country
    column 'Complete', :survey_complete
    column :duplicate
    column :intersex, sortable: "metadata->'intersex'"
    column 'Identity', :gender_identity, sortable: "metadata->'gender'", &:gender_identity_label
    column 'Attraction', :sexual_attraction, sortable: "metadata->'sexual_attraction'", &:sexual_attraction_label
    column 'Attraction Eligibility', :attraction_eligibility, sortable: "metadata->'attraction_eligibility'"
    column 'Orientation', :sexual_orientation, sortable: "metadata->'sexual_orientation'", &:sexual_orientation_label
    column :sgm_group, sortable: "metadata->'sgm_group'"
    column :attraction_sgm_group, sortable: "metadata->'attraction_sgm_group'"
    column :progress, sortable: "metadata->'progress'"
    column :source, &:source_label
    column :metadata
    column :created_at
    actions
  end

  csv do
    column :survey_uuid
    column :email, &:email
    column :phone, &:phone_number
    column :self_gen_id, &:participant_self_gen_id
    column :country
    column :language
    column :id
    column :response_uuid
    column :survey_complete
    column :progress
    column :duration
    column :intersex
    column :gender_identity, &:gender_identity_label
    column :sexual_attraction, &:sexual_attraction_label
    column :attraction_eligibility
    column :sexual_orientation, &:sexual_orientation_label
    column :sgm_group
    column :attraction_sgm_group
    column :source, &:source_label
    column :ip_address
    column :class, &:network_class
    column :network, &:ip_network
    column :host, &:ip_host
    column :created_at
  end

  form do |f|
    f.semantic_errors
    f.inputs do
      input :response_uuid
      input :participant
      input :country, as: :select, collection: %w[Brazil Kenya Vietnam]
      input :survey_complete
      input :duplicate
      input :sgm_group, as: :select, collection: Participant::ALL_SGM_GROUPS
      input :language, as: :select, collection: %w[en sw vi pt-BR]
      input :source, as: :select, collection: %w[0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18]
    end
    f.actions
  end

  controller do
    def scoped_collection
      SurveyResponse.baselines
    end

    def csv_filename
      "Baseline-Surveys-#{Time.now.to_i}.csv"
    end
  end
end
# rubocop:enable Metrics/BlockLength
