# == Schema Information
#
# Table name: response_exports
#
#  id               :bigint           not null, primary key
#  country          :string
#  survey_id        :string
#  progress_id      :string
#  percent_complete :decimal(, )
#  status           :string
#  file_id          :string
#  file_path        :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
class ResponseExport < ApplicationRecord
  after_create :start_export
  after_create { ResponseExportProgressJob.set(wait: 30.seconds).perform_later(id) }

  validates :survey_id, presence: true
  validates :country, presence: true

  def start_export
    return if survey_id.blank? || country.blank?

    url = URI("https://#{Rails.application.credentials.config[:QUALTRICS_BASE_URL]}/surveys/#{survey_id}/export-responses")
    http = create_http(url)
    request = Net::HTTP::Post.new(url)
    update_request_headers(request)
    request.body = JSON.dump(format: 'csv', filterId: filter_id)
    response = http.request(request)
    res_body = JSON.parse(response.body)
    after_export_creation(res_body)
  end

  def update_progress
    return if progress_id.blank?

    url = URI("https://#{Rails.application.credentials.config[:QUALTRICS_BASE_URL]}/surveys/#{survey_id}/export-responses/#{progress_id}")
    http = create_http(url)
    request = Net::HTTP::Get.new(url)
    update_request_headers(request)
    response = http.request(request)
    res_body = JSON.parse(response.body)
    after_export_progress(res_body)
  end

  def download_file
    return if file_id.blank?

    url = URI("https://#{Rails.application.credentials.config[:QUALTRICS_BASE_URL]}/surveys/#{survey_id}/export-responses/#{file_id}/file")
    http = create_http(url)
    request = Net::HTTP::Get.new(url)
    update_request_headers(request)
    response = http.request(request)
    unzip_download(response)
  end

  private

  def filter_id
    case country
    when 'Brazil'
      Rails.application.credentials.config[:BRAZIL_FILTER_ID]
    when 'Kenya'
      Rails.application.credentials.config[:KENYA_FILTER_ID]
    when 'Vietnam'
      Rails.application.credentials.config[:VIETNAM_FILTER_ID]
    end
  end

  def create_http(url)
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    http
  end

  def update_request_headers(request)
    request['Content-Type'] = 'application/json'
    request['X-API-TOKEN'] = Rails.application.credentials.config[:QUALTRICS_TOKEN]
  end

  def after_export_creation(res_body)
    self.progress_id = res_body['result']['progressId']
    self.percent_complete = res_body['result']['percentComplete']
    self.status = res_body['result']['status']
    save
  end

  def after_export_progress(res_body)
    self.file_id = res_body['result']['fileId']
    self.percent_complete = res_body['result']['percentComplete']
    self.status = res_body['result']['status']
    save
  end

  def unzip_download(response)
    create_path
    save_download(response)
    csv = process_scv
    File.new("#{file_path}/#{country}-processed.csv", 'w').write(csv)
  end

  def create_path
    path = "#{Rails.root}/storage/exports/#{Time.now.to_i}"
    FileUtils.mkdir_p(path)
    self.file_path = path
    save
  end

  def save_download(response)
    File.open("#{file_path}/data.zip", 'w') do |io|
      str = response.body
      str.force_encoding('UTF-8')
      io.write(str)
    end
    system("unzip #{file_path}/data.zip -d #{file_path}")
    FileUtils.rm("#{file_path}/data.zip")
    FileUtils.mv(Dir["#{file_path}/*.csv"][0], "#{file_path}/#{country}-raw.csv")
  end

  def process_scv
    filename = Dir["#{file_path}/*.csv"].first
    # puts "filename: #{filename}"
    CSV.generate do |csv|
      index = 0
      invalid_ids = duplicate_identifiers + excluded_identifiers
      headers = []
      CSV.foreach(filename) do |row|
        next if invalid_ids.include?(row[8].strip)

        headers << row if index.zero?
        csv << row if index.zero? || index > 2
        puts row[8] if index < 10
        index += 1
      end
    end
  end

  def duplicate_identifiers
    SurveyResponse.baselines
                  .where(survey_uuid: survey_id)
                  .where(duplicate: true)
                  .pluck(:response_uuid)
  end

  def excluded_identifiers
    participant_ids = Participant.where(include: false).pluck(:id)
    SurveyResponse.baselines
                  .where(participant_id: participant_ids)
                  .where(survey_uuid: survey_id)
                  .pluck(:response_uuid)
  end
end
