require_relative '../config/environment'
require_relative '../db/seeds'
require 'pry'

PROMPT = TTY::Prompt.new

system 'clear'

old_logger = ActiveRecord::Base.logger
ActiveRecord::Base.logger = nil

greet
login



