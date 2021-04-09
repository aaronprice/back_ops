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
$ rails g back_ops:install
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
        }, [
          Subscriptions::Actions::Fulfillment::ChargeCreditCard,
          Subscriptions::Actions::Fulfillment::SendEmailReceipt
        ])
      end
    end
  end
end
```

Each action receives the operation object which contains the context.

```ruby
module Subscriptions
  module Actions
    module Fulfillment
      class ChargeCreditCard
        def self.call(operation)
          subscription_id = operation.get(:subscription_id)
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
params = { 'subscription_id' => subscription.id }
operation = BackOps::Operation.includes(:actions).where("name = 'Subscriptions::Operations::Fulfillment' AND context @> ?", params.to_json).first
```


## Contributing
To contribute to this project. Clone the repo and create a branch for your changes. When complete, create a pull request into the `develop` branch of this project. Ensure that positive and negative test cases cover your changes and all tests pass.

Be detailed in your commit message of what changes you're making and the motivation behind the changes.

## License

Copyright 2021 Aaron Price

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
