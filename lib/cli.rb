$customer = nil

def greet
    puts "******* Welcome to Easy Rez, the simple, user-friendly restaurant booking app! *******"
    sleep(2)
    puts "           Select a restaurant, pick a date and time, then enjoy the food!"
    puts "======================================================================================="
end

def login
    input = PROMPT.ask('First, what is your full name?')
    $customer = Customer.find_or_create_by(name: input)
    puts "Hello #{$customer.name}!"
    sleep(1)
    user_choices_menu
end

def user_choices_menu
    PROMPT.select('What would you like to do?') do |menu|
        menu.choice 'Go To Reservations Menu', -> {reservation_menu}
        menu.choice 'Go To Reviews Menu', -> {review_menu}
        menu.choice 'Exit App', -> {exit_app}
    end
end

def reservation_menu
    PROMPT.select('What would you like to do?') do |menu|
        menu.choice 'Make a Reservation', -> {make_reservation}
        menu.choice 'Change a Reservation', -> {change_reservation}
        menu.choice 'Find All My Reservations', -> {find_all_reservations}
        menu.choice 'Cancel a Reservation', -> {cancel_reservation}
        menu.choice 'Go To Reviews Menu', -> {review_menu}
        menu.choice 'Go To Main Menu', -> {user_choices_menu}
        menu.choice 'Exit App', -> {exit_app}
    end
    user_choices_menu
end


def make_reservation
    result = PROMPT.collect do
        key(:num_of_guests).ask('How many is people is it for?:', convert: :int)
        key(:reservation_time).ask("Please type date and time. example 'YYYY-MM-DD 17:00'", convert: :datetime, required: true)
        key(:restaurant).select("Please select the name of the restaurant:", Hash[Restaurant.all.collect { |restaurant| 
            ["#{restaurant.name}", restaurant] 
        }] )
    end
    Reservation.create(
        num_of_guests: result[:num_of_guests],
        reservation_time: result[:reservation_time],
        customer: $customer,
        restaurant: result[:restaurant]
    )
    reservation_menu
end


def change_reservation
    customer_reservations = $customer.list_reservations
    puts "============================================================="
    reservation_choices = Hash[customer_reservations.collect { |reservation| 
        ["#{reservation.restaurant.name} #{reservation.reservation_time}", reservation] 
    }]
    selected_reservation = PROMPT.select("Choose your reservation to change:", reservation_choices)
    all_restaurants = Restaurant.all
    restaurant_choices = Hash[all_restaurants.collect { |restaurant| 
        ["#{restaurant.name}", restaurant] 
    }]
    result = PROMPT.collect do
        key(:num_of_guests).ask("How many guests will be attending? Currently: #{selected_reservation.num_of_guests}", convert: :int, default: selected_reservation.num_of_guests)
        key(:reservation_time).ask("Please type date and time. example 'YYYY-MM- 17:00'", convert: :datetime, default: selected_reservation.reservation_time.to_s)
    end
    selected_reservation.update(
        num_of_guests: result[:num_of_guests],
        reservation_time: result[:reservation_time], 
        )
    selected_reservation.save
    reservation_menu
end

def find_all_reservations
    puts "Searching for reservations..."
    sleep(1)
    puts "Below are all of your reservations."
    puts "===================================================================================="
    customer_reservations = Reservation.all.select { |reservation| reservation.customer == $customer}
    customer_reservations.each { |reservation| puts "Res ID: #{reservation.id} Time: #{reservation.reservation_time}, Restaurant: #{reservation.restaurant.name} in #{reservation.restaurant.location}, Party of: #{reservation.num_of_guests}"}
    puts "===================================================================================="
    reservation_menu
end


def cancel_reservation
    customer_reservations = $customer.reservations
    puts "========================================================================"
    reservation_choices = Hash[customer_reservations.collect { |reservation| 
        ["#{reservation.restaurant.name} #{reservation.reservation_time}", reservation] 
    }]
    selected_reservation = PROMPT.select("Choose your reservation to cancel:", reservation_choices)
    if PROMPT.yes?("Are you sure?")
        selected_reservation.destroy
    else 
        puts "Sorry, could not confirm."
        sleep(1)
    end
    reservation_menu
end

def review_menu
    PROMPT.select("What would you like to do?") do |menu|
        menu.choice 'Write a Review', -> {make_review}
        menu.choice 'Read My Reviews', -> {find_only_my_reviews}
        menu.choice 'Change a Review', -> {change_review}
        menu.choice 'Read All Restaurant Reviews', -> {find_reviews}
        menu.choice 'Read Reviews By Restaurant', -> {find_restaurant_review}
        menu.choice 'Go To Main Menu', -> {user_choices_menu}
        menu.choice 'Exit App', -> {exit_app}
      end
      user_choices_menu
end


def make_review
    puts "========================================================="
    result = PROMPT.collect do
        key(:restaurant).select("Please select the name of the restaurant:", Hash[Restaurant.all.collect { |restaurant| 
            ["#{restaurant.name}", restaurant] 
        }] )
        key(:description).ask("Please type your review:", required: true)
    end
    Review.create(
        customer: $customer,
        restaurant: result[:restaurant],
        description: result[:description]
    )
    review_menu
end

def find_reviews 
    puts "Below are all restaurant reviews."
    customer_reviews = Review.all
    customer_reviews.map {|review| review.customer}
    puts "========================================================="
    customer_reviews.each { |review| puts "Restaurant: #{review.restaurant.name}, #{review.customer.name} says: #{review.description}"}
    puts "========================================================="
    review_menu
end

def find_only_my_reviews
    puts "Below are your personal restaurant reviews."
    customer_reviews = Review.all.select {|review| review.customer == $customer}
    puts "========================================================="
    customer_reviews.each { |review| puts "Restaurant: #{review.restaurant.name}, My review: #{review.description}"}
    puts "========================================================="
    review_menu
end

def find_restaurant_review
    result = PROMPT.collect do
        key(:restaurant).select("Please select the name of the restaurant:", Hash[Restaurant.all.collect { |restaurant| 
            ["#{restaurant.name}", restaurant] 
        }] )
    end
    restaurant_reviews = Review.all.select { |review| review.restaurant == result[:restaurant] }
    puts "========================================================="
    restaurant_reviews.each { |review| puts "Restaurant: #{review.restaurant.name}, #{review.customer.name} says: #{review.description}"}
    puts "========================================================="
    review_menu
end

def change_review
    puts "========================================================="
    customer_review = $customer.reviews
    if customer_review.length == 0
       puts "Sorry you have no reviews to change."
       puts "========================================================="
    else
        review_choices = Hash[customer_review.collect { |review| 
        ["#{review.restaurant.name}: #{review.description}", review] 
        }]
        selected_review = PROMPT.select("Choose the review to change:", review_choices)
        all_reviews = Review.all
        review_choices = Hash[all_reviews.collect { |review| 
            ["#{review.customer}", review] 
        }]
        result = PROMPT.collect do
            key(:description).ask("Write your new review", default: selected_review.description)
        end
        selected_review.update(description: result[:description])
    selected_review.save
    review_menu
    end
    
end

def exit_app
    sleep(1)
    puts "We hope you enjoyed your experience!"
    sleep(1)
    puts "Goodbye!"
    sleep(2)
    system "clear"
    exit
end

