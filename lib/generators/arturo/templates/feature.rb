# frozen_string_literal: true

require 'active_record'

module Arturo
  class Feature < ::ActiveRecord::Base
    include Arturo::FeatureMethods
  end
end
