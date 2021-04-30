# BackOps

Back Ops is intended for background processing of jobs that require multiple tasks to be completed. It executes each task in sequence in a separate Sidekiq worker. This allows for jobs to be retryable if failures occur, but completed tasks are not retried.

Progress and error states are tracked in the database, so that that you are always aware of what was processed, and if any task fails, where the failure occured in the process, what the error message is, what the stack trace is, so you know what's happening and you can always retry the job from the failed task.

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'back_ops'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install back_ops
```

## Install migrations
Copy the migration from the gem to your application, then run migrations.

```bash
$ rails g back_ops:install --skip
$ rails db:migrate
```

## Usage

There are two parts to this process. First, define an operation, which accepts a set of params, and an array of actions (as the names of the classes those actions will be called). Parameters should be simple types (e.g.: Integer, String, Date/Timestamp) instead of full objects because these params will be sent serialized and sent to redis for each defined task.

```ruby
module Subscriptions
  module Operations
    class Fullfillment
      def self.call(subscription)
        BackOps::Worker.perform_async({
          subscription_id: subscription.id
        }, {
          main: [
            Subscriptions::Actions::Fulfillment::ChargeCreditCard,
            Subscriptions::Actions::Fulfillment::SetupSubscription,
            Subscriptions::Actions::Fulfillment::SendEmailReceipt
          ]
        })
      end
    end
  end
end
```

Each action receives an object with access to all global variables as follows.

```ruby
module Subscriptions
  module Actions
    module Fulfillment
      class ChargeCreditCard
        def self.call(action)
          subscription_id = action.get(:subscription_id)
          subscription = Subscription.find(subscription_id)
          # ...
        end
      end
    end
  end
end
```

You now also have full transparency into each operation and can view it in the admin section by invoking the following code.

```ruby
operation = BackOps::Operation.includes(:actions).
            where(name: 'Subscriptions::Operations::Fulfillment').
            globals_contains(subscription_id: subscription.id).
            first
```

## Branches

Sometimes you need to step through an operation based on conditions. You can accomplish this by using branches. To set this up, define a set of branches that your process can take up front, as follows:

```ruby
module Subscriptions
  module Operations
    class Fullfillment
      def self.call(subscription)
        BackOps::Worker.perform_async({
          subscription_id: subscription.id
        }, {
          main: [
            Subscriptions::Actions::Fulfillment::ChargeCreditCard,
            Subscriptions::Actions::Fulfillment::SendEmailReceipt
          ],
          red_subscriptions: [
            Subscriptions::Actions::Fulfillment::SetupRedSubscription
          ],
          blue_subscriptions: [
            Subscriptions::Actions::Fulfillment::SetupBlueSubscription
          ]
        })
      end
    end
  end
end
```

You can then jump to these branches in the code as follows:

```ruby
module Subscriptions
  module Actions
    module Fulfillment
      class ChargeCreditCard
        def self.call(action)
          subscription_id = action.get(:subscription_id)
          subscription = Subscription.find(subscription_id)
          # ...

          # The following will force the next action
          # to be the first action defined in the
          # :red_subscriptions branch.
          action.jump_to(:red_subscriptions) if subscription.is_red?

          # OR

          # The following will force the next action
          # to be the specified action defined in the
          # :blue_subscriptions branch.
          action.jump_to(blue_subscriptions: Subscriptions::Actions::Fulfillment::SetupBlueSubscription) if subscription.is_blue?
        end
      end
    end
  end
end

# When you're done, jump back to the main branch as follows

module Subscriptions
  module Actions
    module Fulfillment
      class SetupBlueSubscription
        def self.call(action)
          subscription_id = action.get(:subscription_id)
          subscription = Subscription.find(subscription_id)
          # ...

          action.jump_to(main: Subscriptions::Actions::Fulfillment::SendEmailReceipt)
        end
      end
    end
  end
end
```

**NOTE:** Jump does not stop the rest of the action from being processed. It merely sets a pointer to the next action to be processed when the current action is complete. To exit out of an action, simply `return`.


## Contributing
To contribute to this project. Clone the repo and create a branch for your changes. When complete, create a pull request into the `develop` branch of this project. Ensure that positive and negative test cases cover your changes and all tests pass.

Be detailed in your commit message of what changes you're making and the motivation behind the changes.

## License

Copyright 2021 Aaron Price

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
