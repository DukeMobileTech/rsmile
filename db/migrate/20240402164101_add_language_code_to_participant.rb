class AddLanguageCodeToParticipant < ActiveRecord::Migration[6.1]
  def change
    add_column :participants, :language_code, :string, default: 'en'
  end
end
