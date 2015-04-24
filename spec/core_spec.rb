require "spec_helper"

describe ExecuteWithRescue::Mixins::Core do
  describe "#execute_with_rescue" do
    let!(:service_instance) { service_class.new }
    def service_call
      service_instance.call
    end

    context "without a block" do
      let!(:service_class) { TestServiceWithoutBlockInExecute }

      specify do
        expect { service_call }.
          to raise_error(LocalJumpError)
      end
    end

    context "with private method call" do
      let!(:service_class) { TestServiceWithPrivateMethodCallInExecute }

      specify do
        expect { service_call }.
          to_not raise_error
      end
    end

    context "without calling rescue_from" do
      let!(:service_class) { TestServiceWithError }

      specify do
        expect { service_call }.
          to raise_error(StandardError)
      end
    end

    context "with calling rescue_from" do
      let!(:service_class) { TestServiceWithRescue }

      specify do
        expect { service_call }.
          to raise_error(TestServiceWithRescue::CustomError)
      end

      context "with single hook" do
        context "with nothing" do
          describe "in before hook" do
            specify do
              expect do
                TestService.class_eval do
                  add_execute_with_rescue_before_hook
                end
              end.to raise_error(ArgumentError)
            end
          end
          describe "in after hook" do
            specify do
              expect do
                TestService.class_eval do
                  add_execute_with_rescue_after_hook
                end
              end.to raise_error(ArgumentError)
            end
          end
        end

        context "with symbol of a non-existing method name" do
          let!(:temp_class) do
            Class.new(TestServiceWithPrivateMethodCallInExecute).tap do |klass|
              klass.class_eval do
                add_execute_with_rescue_after_hook(:non_existing_method)
              end
            end
          end
          let!(:service_class) { temp_class }

          specify do
            expect { service_call }.
              to raise_error(ExecuteWithRescue::Errors::NoHookMethod)
          end
        end

        context "with symbol of an existing method name" do
          context "with before hook" do
            let!(:service_class) { TestServiceWithSymbolBeforeHook }

            specify do
              expect { service_call }.
                to change { service_instance.hook_exec_count }.
                from(0).to(1)
            end
          end

          context "with after hook" do
            let!(:service_class) { TestServiceWithSymbolAfterHook }

            specify do
              expect { service_call }.
                to change { service_instance.hook_exec_count }.
                from(0).to(1)
            end
          end

          context "with before & after hook" do
            let!(:service_class) { TestServiceWithSymbolBeforeAfterHook }

            specify do
              expect { service_call }.
                to change { service_instance.hook_exec_count }.
                from(0).to(2)
            end
          end
        end

        context "with block" do
          context "with before hook" do
            let!(:service_class) { TestServiceWithBlockBeforeHook }

            specify do
              expect { service_call }.
                to change { service_instance.hook_exec_count }.
                from(0).to(1)
            end
          end

          context "with after hook" do
            let!(:service_class) { TestServiceWithBlockAfterHook }

            specify do
              expect { service_call }.
                to change { service_instance.hook_exec_count }.
                from(0).to(1)
            end
          end

          context "with before & after hook" do
            let!(:service_class) { TestServiceWithBlockBeforeAfterHook }

            specify do
              expect { service_call }.
                to change { service_instance.hook_exec_count }.
                from(0).to(2)
            end
          end
        end

        context "with other type of things" do
          let!(:temp_class) { Class.new(TestService) }

          specify do
            expect do
              temp_class.add_execute_with_rescue_before_hook(1)
            end.to raise_error(ExecuteWithRescue::Errors::UnsupportedHookValue)
          end
        end
      end

      context "with multiple hooks" do
        context "without inheritance" do
          let!(:service_class) { TestServiceWithManySymbolBeforeHook }

          specify do
            expect { service_call }.
              to change { service_instance.hook_exec_count }.
              from(0).to(3)
          end
        end
        context "with inheritance" do
          let!(:service_class) { TestServiceWithManySymbolBeforeHookInherited }

          specify do
            expect { service_call }.
              to change { service_instance.hook_exec_count }.
              from(0).to(5)
          end
        end
      end

      context "with tampered internal class attribuite" do
        let!(:temp_class) do
          Class.new(TestServiceWithPrivateMethodCallInExecute).tap do |klass|
            klass.class_eval do
              _execute_with_rescue_before_hooks << {}
            end
          end
        end
        let!(:service_class) { temp_class }

        specify "after hooks run in reverse order of the define order" do
          expect { service_call }.
            to raise_error(ExecuteWithRescue::Errors::UnsupportedHookValue)
        end
      end

      describe "after hook execution" do
        describe "after an error is raised in block" do
          let!(:service_class) { TestServiceWithErrorAndAfterHook }

          specify "after hooks are run after exception is raised" do
            expect(service_instance.hook_exec_count).to eq(0)

            expect { service_call }.
              to raise_error(RuntimeError)

            expect(service_instance.hook_exec_count).to eq(1)
          end
        end

        describe "order" do
          let!(:service_class) { TestServiceWithManyAfterHooks }

          specify "after hooks run in reverse order of the define order" do
            expect { service_call }.
              to change { service_instance.some_data_array }.
              from([]).to([2, 1])
          end
        end
      end
    end
  end
end
