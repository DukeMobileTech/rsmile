require "administrate/custom_dashboard"

class InvitedUsersDashboard < Administrate::CustomDashboard
  resource "InvitedUsers"
end
