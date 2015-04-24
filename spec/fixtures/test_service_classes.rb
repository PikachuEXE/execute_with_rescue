class TestService
  include ExecuteWithRescue::Mixins::Core

  def call
    # To be overidden
  end
end
class TestServiceWithoutBlockInExecute < TestService
  def call
    execute_with_rescue
  end
end
class TestServiceWithPrivateMethodCallInExecute < TestService
  def call
    execute_with_rescue do
      do_something_privately
    end
  end

  private

  def do_something_privately
    # do nothing
  end
end

class TestServiceWithError < TestService
  include ExecuteWithRescue::Mixins::Core

  def call
    execute_with_rescue do
      fail StandardError
    end
  end
end
class TestServiceWithRescue < TestServiceWithError
  rescue_from StandardError, with: :handle_error

  CustomError = Class.new(StandardError)

  private

  def handle_error
    fail CustomError
  end
end
class TestServiceWithHook < TestServiceWithRescue
  def initialize
    @hook_exec_count = 0
  end

  attr_reader :hook_exec_count

  private

  def handle_error
    # do nothing
  end

  def inc_hook_exec_count
    @hook_exec_count += 1
  end
end
class TestServiceWithSymbolBeforeHook < TestServiceWithHook
  add_execute_with_rescue_before_hook(:inc_hook_exec_count)
end
class TestServiceWithSymbolAfterHook < TestServiceWithHook
  add_execute_with_rescue_after_hook(:inc_hook_exec_count)
end
class TestServiceWithSymbolBeforeAfterHook < TestServiceWithHook
  add_execute_with_rescue_before_hook(:inc_hook_exec_count)
  add_execute_with_rescue_after_hook(:inc_hook_exec_count)
end
class TestServiceWithBlockBeforeHook < TestServiceWithHook
  add_execute_with_rescue_before_hook { inc_hook_exec_count }
end
class TestServiceWithBlockAfterHook < TestServiceWithHook
  add_execute_with_rescue_after_hook { inc_hook_exec_count }
end
class TestServiceWithBlockBeforeAfterHook < TestServiceWithHook
  add_execute_with_rescue_before_hook { inc_hook_exec_count }
  add_execute_with_rescue_after_hook { inc_hook_exec_count }
end

class TestServiceWithManySymbolBeforeHook < TestServiceWithHook
  add_execute_with_rescue_before_hooks(
    :inc_hook_exec_count,
    :inc_hook_exec_count,
    :inc_hook_exec_count,
  )
end
class TestServiceWithManySymbolBeforeHookInherited <
    TestServiceWithManySymbolBeforeHook
  add_execute_with_rescue_before_hook(:inc_hook_exec_count)
  add_execute_with_rescue_before_hook(:inc_hook_exec_count)
end

class TestServiceWithManyAfterHooks < TestServiceWithHook
  add_execute_with_rescue_after_hooks do
    push_some_data(1)
  end
  add_execute_with_rescue_after_hooks do
    push_some_data(2)
  end

  def some_data_array
    @some_data_array ||= []
  end

  private

  def push_some_data(data)
    some_data_array << data
  end
end

class TestServiceWithErrorAndAfterHook < TestServiceWithBlockAfterHook
  def handle_error
    fail RuntimeError
  end
end
