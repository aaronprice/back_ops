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
      globals = { seed: '21b214' }
      locals = { seed: '894f16' }

      expect {
        BackOps::Worker.perform_async(globals, {
          main: [
            Actions::SetToInProgress,
            Actions::SetToBranchOne
          ],
          branch_1: [
            [Actions::SetToProcessed, { perform_at: future_time }]
          ],
          branch_2: [
            [Actions::SetToBranchOne, { locals: locals }]
          ]
        })
        operation = BackOps::Operation.globals_contains(globals).first

        expect(operation.actions.where(perform_at: nil).count).to eq(3)
        expect(operation.actions.where.not(perform_at: nil).count).to eq(1)

        expect(operation.actions.where(branch: 'main').count).to eq(2)
        expect(operation.actions.where(branch: 'branch_1').count).to eq(1)
        expect(operation.actions.where(branch: 'branch_2').count).to eq(1)

        expect(operation.actions.locals_contains(locals).count).to eq(1)
      }.to change(BackOps::Action, :count).by(4)
    end

    it 'sets next_action' do
      globals = { seed: 'fef5fd' }
      locals = { seed: '1e7305' }

      BackOps::Worker.perform_async(globals, {
        main: [
          Actions::SetToInProgress,
          Actions::SetToBranchOne
        ],
        branch_1: [
          [Actions::SetToProcessed, { perform_at: future_time }]
        ],
        branch_2: [
          [Actions::SetToBranchOne, { locals: locals }]
        ]
      })
      operation = BackOps::Operation.globals_contains(globals).first
      expect(operation.next_action).to eq(operation.actions.order(order: :asc).first)
    end

  end
end