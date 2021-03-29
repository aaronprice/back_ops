require 'rails_helper'

RSpec.describe BackOps do

  let(:widget) { create(:widget) }

  it 'creates operation' do
    expect {
      ProcessWidget.call({ widget_id: widget.id })
    }.to change(BackOps::Operation, :count).by(1)
  end

  it 'creates actions' do
    expect {
      ProcessWidget.call({ widget_id: widget.id })
    }.to change(BackOps::Action, :count).by(2)
  end

  it 'processed actions' do 
    expect(widget.state).to eq('new')
    ProcessWidget.call({ widget_id: widget.id })
    widget.reload
    expect(widget.state).to eq('processed')
  end

  it 'completes job' do
    params = { widget_id: widget.id }
    ProcessWidget.call(params)
    operation = BackOps::Operation.where("context @> ?", params.to_json).first
    expect(operation.completed_at.present?).to eq(true)
  end

  it 'completes actions' do
    params = { widget_id: widget.id }
    ProcessWidget.call(params)
    operation = BackOps::Operation.where("context @> ?", params.to_json).first
    completed_actions_count = BackOps::Action.where(operation: operation).where.not(completed_at: nil).count
    expect(completed_actions_count).to eq(2)
  end
end