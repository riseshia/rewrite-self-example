require 'byebug'
require_relative 'code_updater'

class Recipe
  def self.make
    new

    CodeUpdater.new(__dir__, caller.last, meta: { name: name.downcase }).execute
  end
end

if true
  Recipe.make do
    hoge
  end
else
  Recipe.make
end
