# ExecuteWithRescue

Saves your from writing `begin...rescue...ensure...end` everywhere.  
This assumes you know how to use `rescue_from` not just within a controller.  

I write this "gem" because I enocunter this pattern in many background worker and service classes.  
(I use [`interactor`](https://github.com/collectiveidea/interactor) for service classes btw)  
I use this gem, [`rescue_from`](http://api.rubyonrails.org/classes/ActiveSupport/Rescuable/ClassMethods.html) and a custom [`airbrake`](https://github.com/airbrake/airbrake) adapter to add options to Airbrake when notifying, since otherwise you will have to call `Airbrake.notify_or_ignore` manually in `rescue` and pass the options.  
Calling `airbrake` manually sometimes is the best option, but not all the time.  
I might release another gem for that airbrake adapter.  


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'execute_with_rescue'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install execute_with_rescue

## Usage

### `#execute_with_rescue`
**Private** method to be called with a block  
You still have to call `rescue_from` at class level yourself (no magic here)  
```ruby
class SomeServiceClass
  include ExecuteWithRescue::Mixins::Core

  # then run code with possible errors
  def perform
    execute_with_rescue do
      # Something that might causes error
    end
  end
end
```

## Class Methods for adding hooks
"Hooks" are just things to be run before the block and after the block (in `ensure`)  
Beware that the "hooks" execution order are like [`ActiveSupport::Callbacks`](http://api.rubyonrails.org/classes/ActiveSupport/Callbacks.html)  

### `.add_execute_with_rescue_before_hooks`
Alias: `.add_execute_with_rescue_before_hook`
Execution order: Add first, run first
```
class SomeServiceClass
  # Either add hooks by using method names in symbol
  add_execute_with_rescue_before_hook :report_start_by_logging

  # Or add more
  add_execute_with_rescue_before_hooks :do_more, :do_even_more

  # Or in block
  add_execute_with_rescue_before_hook do
    Rails.logger.debug("Some job started")
  end

  private

  def report_start_by_logging
    Rails.logger.debug("Some job started")
  end

  def do_more
    # This execute earlier
  end
  def do_even_more
    # This execute later
  end
end
```

### `.add_execute_with_rescue_after_hooks`
Alias: `.add_execute_with_rescue_after_hook`
Execution order: Add first, run last
```
class SomeServiceClass
  # Either add hooks by using method names in symbol
  add_execute_with_rescue_after_hook :report_end_by_logging

  # Or add more
  add_execute_with_rescue_after_hooks :clean_up_base, :clean_up_more

  # Or in block
  add_execute_with_rescue_after_hook do
    Rails.logger.debug("Some job ended")
  end

  private

  def report_end_by_logging
    Rails.logger.debug("Some job ended")
  end

  def clean_up_base
    # This execute later
  end
  def clean_up_more
    # This execute earlier
  end
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b feature/my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin feature/my-new-feature`)
5. Create new Pull Request
