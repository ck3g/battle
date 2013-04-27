class Battle::Ship
  attr_reader :name

  def initialize(name)
    @name = name
  end

  def is?(name)
    @name == name
  end
end
