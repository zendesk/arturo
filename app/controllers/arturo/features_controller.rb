require 'action_controller'

# TODO: this doesn't do anything radically out of the ordinary.
#       Are there Rails 3 patterns/mixins/methods I can use
#       to clean it up a bit?
module Arturo

  base = Object.const_defined?(:ApplicationController) ? ApplicationController : ActionController::Base

  # Handles all Feature actions. Clients of the Arturo engine
  # should redefine Arturo::FeaturesController#permitted? to
  # return true only for users who are permitted to manage features.
  class FeaturesController < base
    unloadable
    respond_to :html, :json, :xml
    before_filter :require_permission
    before_filter :load_feature, :only => [ :show, :edit, :update, :destroy ]

    def index
      @features = Arturo::Feature.all
      respond_with @features
    end

    def show
      respond_with @feature
    end

    def new
      @feature = Arturo::Feature.new(params[:feature])
      respond_with @feature
    end

    def create
      @feature = Arturo::Feature.new(params[:feature])
      if @feature.save
        flash[:notice] = "Created #{@feature}"
        redirect_to features_path
      else
        flash[:alert] = "Sorry. There was a problem saving the feature."
        render :action => 'new'
      end
    end

    def edit
      respond_with @feature
    end

    def update
      if @feature.update_attributes(params[:feature])
        flash[:notice] = "Updated #{@feature}"
        redirect_to feature_path(@feature)
      else
          flash[:alert] = "Sorry. There was a problem updating #{@feature}."
        render :action => 'edit'
      end
    end

    def destroy
      if @feature.destroy
        flash[:notice] = "Removed #{@feature}."
      else
        flash[:alert] = "Sorry. There was a problem removing #{@feature}."
      end
      redirect_to features_path
    end

    protected

    def require_permission
      unless Arturo.permit_management?(self)
        render :action => 'forbidden', :status => 403
        return false
      end
    end

    def load_feature
      @feature ||= Arturo::Feature.find(params[:id])
    end

  end

end

