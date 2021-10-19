module Admin
  class InvitedUsersController < Admin::ApplicationController
    skip_before_action :require_login, only: [:new, :create]

    def new
      @user = User.new
    end

    def create
      @user = User.new(email: params[:user][:email], password: params[:user][:password])
      @invite_code = params[:invite_code]
      @invite = Invite.find_redeemable(@invite_code)

      # Invite code is present, there is an associated invite, and it is the user's invite
      if @invite_code && @invite && @invite.email == @user.email && !@invite.user_exists?
        if @user.save
          @invite.redeemed!
          # ClearanceMailer.deliver_confirmation @user
          # flash[:notice] = "You will receive an email within the next few minutes. " <<
          #                  "It contains instructions for confirming your account."
          redirect_to admin_user_path(@user)
        else
          render :action => "new"
        end
      else
        flash.now[:notice] = "Sorry, that code is not redeemable"
        render :action => "new"
      end
    end

  end
end
