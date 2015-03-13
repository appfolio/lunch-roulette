# Reads in data from Bamboo HR (https://appfolio.bamboohr.com/employees/directory.php)
# Assumes it's stored in a local HTML file
require 'optparse'
require 'json'
require 'csv'
require 'yaml'
require_relative '../lib/lunch_roulette/config'
require_relative '../lib/lunch_roulette/lunch_group'
require_relative '../lib/lunch_roulette/person'

def main
  options = Hash.new
  o = OptionParser.new do |o|
    o.banner = "Usage: ruby script/bamboo_hr_data.rb data/Employees.html data/new_staff.csv [OPTIONS]"
    o.on('-v', '--verbose', 'Verbose output') { options[:verbose_output] = true }
    o.on('-h', '--help', 'Print this help') { puts o; exit }
    o.parse!
  end

  begin
    raise OptionParser::MissingArgument if not ARGV[0]
    employees_html = "#{ARGV[0]}"
  rescue OptionParser::MissingArgument, NameError
    if !ARGV[0]
      puts "Must specify Employees.html"
    else
      puts "Error attempting to load #{ARGV[0]}"
    end
    puts o
    exit 1
  end

  begin
    raise OptionParser::MissingArgument if not ARGV[1]
    new_staff_csv = "#{ARGV[1]}"
  rescue OptionParser::MissingArgument, NameError
    if !ARGV[0]
      puts "Must specify new_staff.csv"
    else
      puts "Error attempting to load #{ARGV[1]}"
    end
    puts o
    exit 2
  end

  LunchRoulette::Config.new
  employees = nil
  text = File.open(employees_html).read
  text.gsub!(/\r\n?/, "\n")
  text.each_line do |line|
    # look for the JS variable snippet
    if line =~ /var data=(.*);/
      puts $1 if options[:verbose_output]
      employees = JSON.parse($1) # optimistically, this should work fine
      break
    end
  end

  csv = CSV.open(new_staff_csv, "w")
  if employees
    csv << %w(user_id name email start_date team lunchable)
    employees.each do |employee|
      person = load_person(employee)
      store_person(csv, person) if person
    end
  end

  csv.close

  if options[:verbose_output]
    puts
    csv_text = File.open(new_staff_csv).read
    puts csv_text
    puts "Staff file written to: #{new_staff_csv}"
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

