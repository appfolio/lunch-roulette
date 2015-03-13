# Reads in data from Bamboo HR (https://appfolio.bamboohr.com/employees/directory.php)
# Assumes it's stored in a local HTML file
require 'json'
require 'csv'
require 'yaml'
require_relative '../lib/lunch_roulette/config'
require_relative '../lib/lunch_roulette/lunch_group'
require_relative '../lib/lunch_roulette/person'

def main
  LunchRoulette::Config.new
  employees = nil
  text = File.open("data/Employees.html").read
  text.gsub!(/\r\n?/, "\n")
  text.each_line do |line|
    # look for the JS variable snippet
    if line =~ /var data=(.*);/
      employees = JSON.parse($1) # optimistically, this should work fine
      break
    end
  end

  csv = CSV.open("data/new_staff.csv", "w")
  if employees
    csv << %w(user_id name email start_date team lunchable)
    employees.each do |employee|
      person = load_person(employee)
      store_person(csv, person) if person
    end
  end
end

def load_person(employee)
  return if employee['location'] != 'Santa Barbara' # expand geographically later
  return if employee['workEmail'].nil? || employee['workEmail'] == ''
  name = (employee['nickname'] != '' ?
      "#{employee['nickname']} #{employee['lastName']}" :
      "#{employee['firstName']} #{employee['lastName']}")
  hash = {
      'user_id' => employee['workEmail'], # Bamboo HR only exports the real id for the logged-in user
      'name' => name,
      'email' => employee['workEmail'],
      'start_date' => Time.now.strftime('%m/%d/%Y'),
      'team' => employee['department'],
      'lunchable' => 'TRUE', # TODO: should this be opt-in instead?
  }
  LunchRoulette::Person.new(hash)
rescue => e
  warn(e)
  raise e
end

def store_person(csv, person)
  csv << [person.user_id, person.name, person.email, person.start_date, person.team, person.lunchable]
end


main

