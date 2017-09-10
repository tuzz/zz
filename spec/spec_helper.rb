require "rspec"
require "pry"
require "fileutils"
require "zz"

RSpec.configure do |config|
  config.disable_monkey_patching!
  config.formatter = :doc
  config.color = true
end
