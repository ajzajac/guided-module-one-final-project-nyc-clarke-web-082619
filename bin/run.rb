require_relative '../config/environment'
require_relative '../db/seeds'
require 'pry'

PROMPT = TTY::Prompt.new

system 'clear'

greet
login



