require 'rails_helper'

RSpec.describe BackOps::Worker do

  let(:widget) { create(:widget) }
  let(:future_time) { 10.minutes.from_now }

  describe 'perform_async' do

    before {
      allow_any_instance_of(BackOps::Worker).to receive(:perform).with(anything).and_return(true)
    }

    it 'requires actions' do
      expect {
        BackOps::Worker.perform_async({}, {})
      }.to raise_error(ArgumentError, 'Cannot process empty actions')
    end

    it 'creates actions' do
      context = { seed: '21b214' }
      locals = { seed: '894f16' }

      expect {
        BackOps::Worker.perform_async(context, {
          main: [
            Actions::SetToInProgress,
            Actions::SetToPathOne
          ],
          path_1: [
            [Actions::SetToProcessed, { perform_at: future_time }]
          ],
          path_2: [
            [Actions::SetToPathOne, { locals: locals }]
          ]
        })
        operation = BackOps::Operation.context_contains(context).first

        expect(operation.actions.where(perform_at: nil).count).to eq(3)
        expect(operation.actions.where.not(perform_at: nil).count).to eq(1)

        expect(operation.actions.where(path: 'main').count).to eq(2)
        expect(operation.actions.where(path: 'path_1').count).to eq(1)
        expect(operation.actions.where(path: 'path_2').count).to eq(1)

        expect(operation.actions.locals_contains(locals).count).to eq(1)
      }.to change(BackOps::Action, :count).by(4)
    end

    it 'sets next_action' do
      context = { seed: 'fef5fd' }
      locals = { seed: '1e7305' }

      BackOps::Worker.perform_async(context, {
        main: [
          Actions::SetToInProgress,
          Actions::SetToPathOne
        ],
        path_1: [
          [Actions::SetToProcessed, { perform_at: future_time }]
        ],
        path_2: [
          [Actions::SetToPathOne, { locals: locals }]
        ]
      })
      operation = BackOps::Operation.context_contains(context).first
      expect(operation.next_action).to eq(operation.actions.order(order: :asc).first)
    end

  end
end