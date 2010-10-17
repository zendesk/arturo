require 'active_support/core_ext/module'

module Arturo

  # A block that, when passed a Controller instance, returns
  # true iff the current user can manage features.
  mattr_writer :permit_management
  @@permit_management = lambda { false }

  # Set Arturo's permission block.
  # @param [block] block
  # @see Arturo.permission_block
  def self.permit_management(&block)
    if block
      @@permit_management = block
    end
    @@permit_management
  end

  def self.permit_management?(controller)
    block = self.permit_management
    block && block.call(controller)
  end
end
