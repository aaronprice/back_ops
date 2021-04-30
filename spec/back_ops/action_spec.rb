require 'rails_helper'

RSpec.describe BackOps::Action do

  let(:operation) { create(:operation) }
  let(:action) { create(:action, operation: operation) }

  describe 'jump_to' do

    it 'rejects anything but a symbol or hash' do
      expect {
        action.jump_to([])
      }.to raise_error(ArgumentError, 'jump_to only accepts as Symbol or a Hash')
    end

    it 'explodes if no next action found' do
      expect {
        action.jump_to(:does_not_exist)
      }.to raise_error(RuntimeError, 'Could not jump_to(:does_not_exist). Action not found.')
    end

    it 'works with symbol' do
      BackOps::Action.delete_all

      new_action = create(:action,
        operation: operation,
        name: 'TestAction',
        branch: 'main'
      )
      expect(operation.next_action_id).to eq(nil)
      action.jump_to(:main)
      expect(operation.next_action_id).to eq(new_action.id)
    end

    it 'works with hash' do
      new_action = create(:action,
        operation: operation,
        name: 'TestAction',
        branch: 'main'
      )
      expect(operation.next_action_id).to eq(nil)
      action.jump_to(main: 'TestAction')
      expect(operation.next_action_id).to eq(new_action.id)
    end

  end

  describe 'get' do
    it 'exists' do
      seed = '307f8e'
      operation.globals = { seed: seed }
      operation.save!

      expect(action.get(:seed)).to eq(seed)
    end

    it 'does not exist' do
      operation.globals = {}
      operation.save!

      expect(action.get(:seed)).to eq(nil)
    end
  end

  describe 'set' do
    it 'does not exist' do
      operation.globals = {}
      operation.save!

      seed = '7cacaf'
      action.set(:seed, seed)

      expect(action.get(:seed)).to eq(seed)
    end

    it 'exists' do
      seed = '307f8e'
      operation.globals = { seed: seed }
      operation.save!

      new_seed = 'e240aa'
      action.set(:seed, new_seed)
      expect(action.get(:seed)).to eq(new_seed)
    end
  end

  describe 'premature?' do
    it 'blank' do
      expect(action.premature?).to eq(false)
    end

    it 'past' do
      action.perform_at = 1.second.ago
      expect(action.premature?).to eq(false)
    end

    it 'future' do
      action.perform_at = 1.second.from_now
      expect(action.premature?).to eq(true)
    end
  end
end