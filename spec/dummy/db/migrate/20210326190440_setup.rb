class Setup < ActiveRecord::Migration[6.1]
  def change
    create_table :widgets do |t|
      t.string :state
    end
  end
end
