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
      PERMITTED_ATTRIBUTES = [ :symbol, :deployment_percentage ]

      def feature_params
        if feature = params[:feature]
          feature.permit(PERMITTED_ATTRIBUTES)
        end
      end

      def features_params
        features = params[:features]
        features.each do |id, attributes|
          attributes = attributes.to_unsafe_h if attributes.respond_to?(:to_unsafe_h)
          features[id] = ActionController::Parameters.new(attributes).permit(*PERMITTED_ATTRIBUTES)
        end
      end
    end

    include defined?(ActionController::Parameters) ? WithStrongParams : WithoutStrongParams

  end

end
