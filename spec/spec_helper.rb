if ENV["TRAVIS"]
  require 'coveralls'
  Coveralls.wear!
end

require 'execute_with_rescue'

require 'fixtures/test_service_classes'
require 'rspec'

require 'logger'

RSpec.configure do |config|
end
