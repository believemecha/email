class ApplicationController < ActionController::Base
    protect_from_forgery
  
    #
    # redirect registered users to a profile page
    # of to the admin dashboard if the user is an administrator
    #
    def after_sign_in_path_for(resource)
        current_user.admin? ? develop_dashboard_index_path : '/home'
    end
  
    def authenticate_admin_user!
      redirect_to root_path if (!current_user.present? || !current_user.admin?)
    end

    def destroy_admin_user
        super
    end
  
    rescue_from SecurityError do |exception|
      redirect_to root_path
    end
  end