# frozen_string_literal: true
class User

  attr_reader :name, :id

  def initialize(options = {})
    @name = options[:name]
    @admin = options[:admin]
    @id = options[:id]
  end

  def admin?
    !!@admin
  end

  def to_s
    name
  end

  def inspect
    type = @admin ? 'Admin' : 'User'
    "<Mock #{type} ##{id}: #{name}>"
  end

end
