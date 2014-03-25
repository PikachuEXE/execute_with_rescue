module ExecuteWithRescue
  module Errors
    NoHookMethod = Class.new(NoMethodError)
    UnsupportedHookValue = Class.new(ArgumentError)
  end
end
