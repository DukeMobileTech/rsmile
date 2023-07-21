class ResponseExportProgressJob < ApplicationJob
  queue_as :rs_qualtrics

  def perform(response_export_id)
    response_export = ResponseExport.where(id: response_export_id).first
    return unless response_export

    response_export.update_progress
    response_export.reload
    response_export.download_file if response_export.status == 'complete' && response_export.file_path.blank?
    return unless response_export.status == 'inProgress'

    ResponseExportProgressJob.set(wait: 30.seconds).perform_later(response_export_id)
  end
end
