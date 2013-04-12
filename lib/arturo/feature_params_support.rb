module Arturo

  # Mix in to FeaturesController. Provides the logic for getting parameters
  # for creating/updated features out of the request.
  module FeatureParamsSupport

    module WithoutStrongParams
      def feature_params
        params[:feature] || {}
      end

      def features_params
        params[:features] || {}
      end
    end

    module WithStrongParams
      PERMITTED_ATTRIBUTES = [ :symbol, :deployment_percentage, :owner_email, :reason_to_keep_forever, :phase, :external_beta_subdomains ]

      def feature_params
        params.permit(:feature => PERMITTED_ATTRIBUTES)[:feature]
      end

      def features_params
        permitted = PERMITTED_ATTRIBUTES
        features = params[:features]
        features.each do |id, attributes|
          features[id] = ActionController::Parameters.new(attributes).permit(*permitted)
        end
      end
    end

    include defined?(ActionController::Parameters) ? WithStrongParams : WithoutStrongParams

  end

end

