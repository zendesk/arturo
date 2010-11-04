class User

  attr_reader :name

  def initialize(options = {})
    @name = options[:name]
    @admin = options[:admin]
  end

  def admin?
    !!@admin
  end

end
