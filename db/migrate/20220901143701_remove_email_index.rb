class RemoveEmailIndex < ActiveRecord::Migration[6.1]
  def change
    remove_index :participants, :email
    remove_column :participants, :study_id
    remove_column :participants, :resume_code
    add_index :participants, :email
    add_column :participants, :name, :string
  end
end
