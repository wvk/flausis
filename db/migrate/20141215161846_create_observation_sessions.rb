class CreateObservationSessions < ActiveRecord::Migration
  def change
    create_table :observation_sessions do |t|
      t.datetime :start_time
      t.datetime :end_time
      t.boolean :at_night

      t.timestamps
    end

    add_column :events, :observation_session_id, :integer
    add_column :images, :observation_session_id, :integer
    add_column :precipitations, :observation_session_id, :integer
    add_column :temperatures, :observation_session_id, :integer
  end
end
