class Restaurant < ActiveRecord::Base
    has_many :customers, through: :reservations
    has_many :reservations
    has_many :reviews
end
