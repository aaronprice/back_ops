require 'rails_helper'

RSpec.describe BackOps::Worker do

  let(:widget) { create(:widget) }

  it 'requires actions' do
    expect {
      BackOps::Worker.perform_async({}, [])
    }.to raise_error(ArgumentError)
  end

end