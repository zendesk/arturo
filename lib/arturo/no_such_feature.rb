module Arturo

  # A Null-Object stand-in for a Feature.
  class NoSuchFeature

    attr_reader :symbol

    def initialize(symbol)
      raise ArgumentError.new(I18n.t('arturo.no_such_feature.symbol_required')) if symbol.nil?
      @symbol = symbol
    end

    def enabled_for?(feature_recipient)
      false
    end

    def name
      I18n.t('arturo.no_such_feature.to_s', :symbol => symbol)
    end

    alias_method :to_s, :name

    def inspect
      "<Arturo::NoSuchFeature #{symbol}>"
    end

  end

end
