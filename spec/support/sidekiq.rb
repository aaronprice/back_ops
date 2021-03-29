RSpec.configure do |config|
  Sidekiq::Testing.inline!
end