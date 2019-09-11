$customer = nil

def greet
    puts "Welcome to Easy Rez, the simple, user-friendly restaurnt booking app!"
    puts "======================================================================="
end

def login
    prompt = TTY::Prompt.new
    input = prompt.ask('What is your name?')
    $customer = Customer.find_or_create_by(name: input)
    puts "Hello #{$customer.name}!"
    user_choices_menu
end


def user_choices_menu
    prompt = TTY::Prompt.new
    prompt.select('What would you like to do?') do |menu|
        menu.choice 'Make a reservation', -> {make_reservation}
        menu.choice 'Change a reservation', -> {change_reservation}
        menu.choice 'Find all my reservations', -> {find_all_reservations}
        menu.choice 'Cancel a reservation', -> {cancel_reservation}
        menu.choice 'Exit', 5
    end
end


def make_reservation
    prompt = TTY::Prompt.new
    result = prompt.collect do
        key(:num_of_guests).ask('How many is people is it for?:', convert: :int)
        key(:reservation_time).ask("Please type date and time. example '2019-09-10 17:00'", convert: :datetime, required: true)
        key(:restaurant).select("Please select the name of the restaurant:", Hash[Restaurant.all.collect { |restaurant| 
            ["#{restaurant.id} #{restaurant.name}", restaurant] 
        }] )
    end
    Reservation.create(
        num_of_guests: result[:num_of_guests],
        reservation_time: result[:reservation_time],
        customer: $customer,
        restaurant: result[:restaurant]
    )

    user_choices_menu
end


def change_reservation
    prompt = TTY::Prompt.new
    customer_reservations = $customer.list_reservations
    reservation_choices = Hash[customer_reservations.collect { |reservation| 
        ["#{reservation.id} #{reservation.restaurant.name} #{reservation.reservation_time}", reservation] 
    }]
    selected_reservation = prompt.select("Choose your reservation to change:", reservation_choices)
    all_restaurants = Restaurant.all
    restaurant_choices = Hash[all_restaurants.collect { |restaurant| 
        ["#{restaurant.id} #{restaurant.name}", restaurant] 
    }]
    result = prompt.collect do
        key(:num_of_guests).ask("How many guests will be attending? Currently: #{selected_reservation.num_of_guests}", convert: :int, default: selected_reservation.num_of_guests)
        key(:reservation_time).ask("Please type date and time. example '2019-09-10 17:00'", convert: :datetime, default: selected_reservation.reservation_time.to_s)
        key(:restaurant).select("Please select the name of the restaurant:", restaurant_choices, default: all_restaurants.index(selected_reservation.restaurant)+1)
    end
    selected_reservation.update(
        num_of_guests: result[:num_of_guests],
        reservation_time: result[:reservation_time],
        restaurant: result[:restaurant] )
    selected_reservation.save
    user_choices_menu
end

def find_all_reservations
    puts "Searching for reservations..."
    prompt = TTY::Prompt.new
    customer_reservations = Reservation.all.select {|reservation| reservation.customer == $customer}
    customer_reservations.each {|reservation| puts "ID: #{reservation.id} Time: #{reservation.reservation_time}, Restaurant: #{reservation.restaurant.name}, Party of: #{reservation.num_of_guests}"}
    user_choices_menu
end

def cancel_reservation
    prompt = TTY::Prompt.new
    customer_reservations = $customer.list_reservations
    reservation_choices = Hash[customer_reservations.collect { |reservation| 
        ["#{reservation.restaurant.name} #{reservation.reservation_time}", reservation] 
    }]
    selected_reservation = prompt.select("Choose your reservation to cancel:", reservation_choices)
    if prompt.yes?("Are you sure?")
        selected_reservation.destroy
    else 
        puts "Could not confirm."
    end

    user_choices_menu
end




