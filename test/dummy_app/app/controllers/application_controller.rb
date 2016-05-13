# frozen_string_literal: true
class ApplicationController < ActionController::Base
  protect_from_forgery

  layout 'application'

  def current_user
    User.new(:name => 'Freddykins', :admin => true)
  end
end
