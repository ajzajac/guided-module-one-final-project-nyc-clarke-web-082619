class Customer < ActiveRecord::Base
    has_many :restaurants, through: :reservations
    has_many :reservations
    has_many :reviews
    
    def list_reservations
      Reservation.all.select {|reservation| reservation.customer_id == self.id}
    end

    def get_restaurants
        list_reservations.map {|reservation| reservation.restaurant}
    end


end
    