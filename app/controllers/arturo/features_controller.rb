require 'action_controller'

module Arturo

  # Handles all Feature actions. Clients of the Arturo engine
  # should redefine Arturo::FeaturesController#permitted? to
  # return true only for users who are permitted to manage features.
  class FeaturesController < ApplicationController
    include Arturo::FeatureManagement

    before_filter :require_permission
    before_filter :load_feature, :only => [ :show, :edit, :update, :destroy ]

    def index
      @features = Arturo::Feature.all
      respond_to do |format|
        format.html { }
        format.json { render :json => @features }
        format.xml  { render :xml  => @features }
      end
    end

    def update_all
      updated_count = 0
      errors = []
      features_params = params[:features] || {}
      features_params.each do |id, attributes|
        feature = Arturo::Feature.find_by_id(id)
        if feature.blank?
          errors << t('arturo.features.flash.no_such_feature', :id => id)
        elsif feature.update_attributes(attributes)
          updated_count += 1
        else
          errors << t('arturo.features.flash.error_updating', :id => id)
        end
      end
      if errors.any?
        flash[:error] = errors
      else
        flash[:success] = t('arturo.features.flash.updated_many', :count => updated_count)
      end
      redirect_to features_path
    end

    def show
      respond_to do |format|
        format.html { }
        format.json { render :json => @feature }
        format.xml  { render :xml  => @feature }
      end
    end

    def new
      @feature = Arturo::Feature.new(params[:feature])
      respond_to do |format|
        format.html { }
        format.json { render :json => @feature }
        format.xml  { render :xml  => @feature }
      end
    end

    def create
      @feature = Arturo::Feature.new(params[:feature])
      if @feature.save
        flash[:notice] = t('arturo.features.flash.created', :name => @feature.to_s)
        redirect_to features_path
      else
        flash[:alert] = t('arturo.features.flash.error_creating', :name => @feature.to_s)
        render :action => 'new'
      end
    end

    def edit
      respond_to do |format|
        format.html { }
        format.json { render :json => @feature }
        format.xml  { render :xml  => @feature }
      end
    end

    def update
      if @feature.update_attributes(params[:feature])
        flash[:notice] = t('arturo.features.flash.updated', :name => @feature.to_s)
        redirect_to feature_path(@feature)
      else
          flash[:alert] = t('arturo.features.flash.error_updating', :name => @feature.to_s)
        render :action => 'edit'
      end
    end

    def destroy
      if @feature.destroy
        flash[:notice] = t('arturo.features.flash.removed', :name => @feature.to_s)
      else
        flash[:alert] = t('arturo.features.flash.error_removing', :name => @feature.to_s)
      end
      redirect_to features_path
    end

    protected

    def require_permission
      unless may_manage_features?
        render :action => 'forbidden', :status => 403
        return false
      end
    end

    def load_feature
      @feature ||= Arturo::Feature.find(params[:id])
    end

  end

end

