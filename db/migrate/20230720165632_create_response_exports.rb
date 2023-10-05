class CreateResponseExports < ActiveRecord::Migration[6.1]
  def change
    create_table :response_exports do |t|
      t.string :country
      t.string :survey_id
      t.string :progress_id
      t.decimal :percent_complete
      t.string :status
      t.string :file_id
      t.string :file_path

      t.timestamps
    end
  end
end
