# frozen_string_literal: true

class CreateBackOpsTables < ActiveRecord::Migration[6.1]
  def change
    create_table :back_ops_operations do |t|
      t.string :name
      t.string :params_hash
      t.jsonb :globals, null: false, default: {}
      t.integer :next_action_id, limit: 8
      t.timestamp :completed_at

      t.timestamps
    end

    add_index :back_ops_operations, [:name, :params_hash]

    create_table :back_ops_actions do |t|
      t.integer :operation_id, limit: 8
      t.integer :order, null: false, default: 0
      t.text :branch
      t.text :name
      t.timestamp :perform_at
      t.text :error_message
      t.text :stack_trace
      t.timestamp :errored_at
      t.timestamp :completed_at
      t.integer :attempts_count, null: false, default: 0

      t.timestamps
    end

    add_index :back_ops_actions, :operation_id
  end
end