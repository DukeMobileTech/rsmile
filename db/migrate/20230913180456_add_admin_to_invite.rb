class AddAdminToInvite < ActiveRecord::Migration[6.1]
  def change
    add_column :invites, :admin, :boolean, default: false
  end
end
