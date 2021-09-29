class Api::ApiController < ActionController::API
  include ApiKeyAuthenticatable
  # Require token authentication
  prepend_before_action :authenticate_with_api_key!

end
