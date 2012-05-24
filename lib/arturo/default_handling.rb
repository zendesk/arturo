module Arturo
  module DefaultHandling
                    
    def _enabled_for?(feature_recipient)
      passes_threshold?(feature_recipient)
    end
    private :_enabled_for?
    
  end
end
