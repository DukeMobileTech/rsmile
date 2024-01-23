ActiveAdmin.register Participant, as: 'Seed' do
  menu label: 'RDS Seeds'
  menu priority: 2

  member_action :send_invite, method: :get do
    redirect_to resource_path
  end

  action_item :send_invite, only: :show do
    link_to 'Send Invite', send_invite_admin_seed_path(params[:id])
  end

  controller do
    def scoped_collection
      Participant.seeds
    end

    def send_invite
      @participant = Participant.find(params[:id])
      RdsMailer.with(participant: @participant).start_rds_email.deliver_now
      redirect_to(admin_seeds_path, notice: "RDS invite sent to #{@participant.email}")
    end
  end
end
