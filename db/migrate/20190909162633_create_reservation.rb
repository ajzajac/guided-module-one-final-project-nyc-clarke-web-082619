class CreateReservation < ActiveRecord::Migration[5.0]
  def change
    create_table :reservations do |t|
      t.datetime :reservation_time
      t.integer :num_of_guests
      t.integer :customer_id
      t.integer :restaurant_id
    end
  end
end