require 'active_support/core_ext/module'

module Arturo

  # A block that, when bound to a Controller instance, returns
  # true iff the current user can manage features.
  mattr_writer :permit_management
  @@permit_management = lambda { false }

  # A block that, when bound to a Controller or Helper instance,
  # returns an object (probably a User, Person, or Account),
  # that may or may not have features enabled.
  mattr_writer :feature_recipient
  @@feature_recipient = lambda { nil }

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
  def self.feature_recipient(&block)
    if block
      @@feature_recipient = block
    end
    @@feature_recipient
  end

end
