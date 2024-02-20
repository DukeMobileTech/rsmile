# rubocop:disable Metrics/BlockLength
ActiveAdmin.register Invite do
  permit_params :first_name, :last_name, :email, :password, :admin

  member_action :send_invite, method: :get do
    redirect_to resource_path
  end

  action_item :send_invite, only: :show do
    link_to 'Send Invite', send_invite_admin_invite_path(params[:id])
  end

  form title: 'Invite User' do |f|
    inputs 'Details' do
      input :first_name
      input :last_name
      input :email
      f.input :admin
    end
    actions
  end

  controller do
    skip_before_action :require_login, only: %i[new_invite redeem_invite]

    def send_invite
      @invite = Invite.find(params[:id])
      @invite.invite!
      InviteMailer.with(invite: @invite).invite_email.deliver_now
      redirect_to(admin_invites_path, notice: "Invite sent to #{@invite.email}")
    end

    def new_invite
      @user = User.new
    end

    def redeem_invite
      @user = User.new(email: params[:user][:email], password: params[:user][:password])
      @invite_code = params[:invite_code]
      @invite = Invite.find_redeemable(@invite_code)

      # Invite code is present, there is an associated invite, and it is the user's invite
      if @invite_code && @invite && @invite.email == @user.email && !@invite.user_exists?
        @user.admin = @invite.admin
        if @user.save
          @invite.redeemed!
          # ClearanceMailer.deliver_confirmation @user
          # flash[:notice] = "You will receive an email within the next few minutes. " <<
          #                  "It contains instructions for confirming your account."
          if @user.admin?
            redirect_to admin_user_path(@user)
          else
            redirect_to root_path
          end
        else
          render action: 'new'
        end
      else
        flash.now[:notice] = 'Sorry, that code is not redeemable'
        render action: 'new'
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
