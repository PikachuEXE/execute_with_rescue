require 'active_support/concern'
require 'active_support/rescuable'
require 'active_support/core_ext/class/attribute'

require 'execute_with_rescue/errors'

module ExecuteWithRescue
  module Mixins
    module Core
      extend ActiveSupport::Concern

      included do
        include ActiveSupport::Rescuable

        # Use active support or inheritance will be broken
        class_attribute :_execute_with_rescue_before_hooks,
                        instance_reader: true,
                        instance_writer: false
        self._execute_with_rescue_before_hooks = []
        class_attribute :_execute_with_rescue_after_hooks,
                        instance_reader: true,
                        instance_writer: false
        self._execute_with_rescue_after_hooks = []

        class << self
          # Pass method names or/and a block to be executed before yield
          #
          # @param method_names [Array<Symbol>]
          #   instance methods names to be run before yield
          # @param block [Proc]
          #   a block to be executed with no argument
          #   in the instance before yield
          #   It will be appended after method_names if both given
          #
          # @note These hooks are inherited
          #
          # @example Add a hook to begin some logging
          #   add_execute_with_rescue_before_hooks(:log_start)
          #
          # @raise [ArgumentError]
          #   if neither method_names and block is given
          def add_execute_with_rescue_before_hooks(*method_names, &block)
            _validate_execute_with_rescue_hook!(method_names, block)

            # Must use setter to avoid changing parent setting
            self._execute_with_rescue_before_hooks =
              [
                self._execute_with_rescue_before_hooks,
                # Add method names first, block later
                method_names,
                block,
              ].flatten.compact
          end
          alias_method :add_execute_with_rescue_before_hook,
                       :add_execute_with_rescue_before_hooks

          # Pass method names or/and a block to be executed after yield
          # Similar to add_execute_with_rescue_before_hooks
          #
          # @see add_execute_with_rescue_before_hooks
          def add_execute_with_rescue_after_hooks(*method_names, &block)
            _validate_execute_with_rescue_hook!(method_names, block)

            # Must use setter to avoid changing parent setting
            self._execute_with_rescue_after_hooks =
              [
                self._execute_with_rescue_after_hooks,
                # Add method names first, block later
                method_names,
                block,
              ].flatten.compact
          end
          alias_method :add_execute_with_rescue_after_hook,
                       :add_execute_with_rescue_after_hooks

          # @private
          # @discuss
          #   Should this moved into another module?
          #   (without being mixed in)
          def _validate_execute_with_rescue_hook!(method_names, block)
            raise ArgumentError if (method_names.empty? && block.nil?)
            raise ExecuteWithRescue::Errors::UnsupportedHookValue unless
              method_names.all?{|m| m.is_a?(Symbol)}
          end
        end
      end

      private

      # Wrapper method for rescuing known errors
      # after you have call `rescue_from` at class level
      # This saves you from typing:
      # ```
      # being
      #   # Some code that might cause exception
      # rescue
      #   rescue_with_handler(exception) || raise
      # end
      # ````
      # Remember to `next` instead of `return` if you want to terminate
      #
      # You can use `alias_method` to create a shorter alias, I use `execute`
      # But some gem might use that name already, so be careful
      #
      # @param block [Proc]
      #   a block to be executed
      #
      # @note
      #   Use `next` for termination, since `return` in block does not work
      # @note
      #   Although we rescue Exception here,
      #   but normally we should NOT handle them without re-raise
      #
      # @example Use with gem `interactor`
      #   class DoSomething
      #     include Interactor
      #     include ExecuteWithRescue::Mixins::Core
      #
      #     def perform
      #       execute_with_rescue do
      #         # Do something
      #       end
      #     end
      #   end
      #
      # @raise [LocalJumpError]
      #   When you call return in block
      def execute_with_rescue
        _run_execute_with_rescue_before_hooks
        yield
      rescue Exception => exception
        rescue_with_handler(exception) || raise
      ensure
        _run_execute_with_rescue_after_hooks
      end

      # @private
      def _run_execute_with_rescue_before_hooks
        _execute_with_rescue_before_hooks.each do |before_hook|
          _run_execute_with_rescue_hook(before_hook)
        end
      end

      # @private
      def _run_execute_with_rescue_after_hooks
        _execute_with_rescue_after_hooks.reverse.each do |after_hook|
          _run_execute_with_rescue_hook(after_hook)
        end
      end

      # @private
      def _run_execute_with_rescue_hook(method_name_or_block)
        case method_name_or_block
        when Symbol
          begin
            self.send(method_name_or_block)
          rescue NoMethodError
            raise ExecuteWithRescue::Errors::NoHookMethod,
                  "method `#{method_name_or_block}` does not exists"
          end
        # block are converted to Proc as argument
        when Proc
          instance_eval(&method_name_or_block)
        else
          # This should not happen unless someone tamper the class attribute
          # without using the provided methods
          raise ExecuteWithRescue::Errors::UnsupportedHookValue
        end
      end
    end
  end
end
