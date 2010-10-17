require 'active_support/core_ext/module'

module Arturo

  # A block that, when bound to a Controller instance, returns
  # true iff the current user can manage features.
  mattr_writer :permit_management
  @@permit_management = lambda { false }

  # A block that, when bound to a Controller or Helper instance,
  # returns an object (probably a User, Person, or Account),
  # that may or may not have features enabled.
  mattr_writer :thing_that_has_features
  @@thing_that_has_features = lambda { nil }

  # Get or set Arturo's permission block.
  # @param [block] block
  # @return [block]
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

  # Get or set Arturo's block for retrieving the
  # thing that may or may not have features enabled.
  # @param [block] block
  # @return [block]
  # @see Arturo.permission_block
  def self.thing_that_has_features(&block)
    if block
      @@thing_that_has_features = block
    end
    @@thing_that_has_features
  end

end
