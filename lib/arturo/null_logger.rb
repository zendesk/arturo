module Arturo
  class NullLogger
    %w[info debug error fatal warn].each do |level|
      define_method level do |_message|
      end
    end
  end
end
