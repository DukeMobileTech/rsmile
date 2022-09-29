class StaticPagesController < ApplicationController
  skip_before_action :require_login
  def glossary
    render 'static_pages/glossary', layout: false
  end
end
