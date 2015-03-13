Command Line App From The Future
================================

In the future, AppFolio caters to all your daily needs, including social interaction during lunch hour.

Lunch Roulette is a command line application that always requires a CSV file with staff "features", such as their team and specialty and start date. It is run using the ruby executable and specifying the staff via a CSV file:

```ruby
ruby lib/lunch_roulette.rb data/staff.csv
```

Features are things like the team that a staffer is on, or the day they started. These features can be weighted in different ways and mapped so that some values are "closer" to others.

Along with specifying the various weights and mappings Lunch Roulette users, configurable options include the number of people per group, the number of iterations to perform, and the number of groups to output:

```
Usage: ruby lib/lunch_roulette.rb data/staff.csv [OPTIONS]
  -n, --min-group-size N           Minimum Lunch Group Size (default 4)
  -i, --iterations I               Number of Iterations (default 1,000)
  -m, --most-varied-sets M         Number of most varied sets to generate (default 1)
  -l, --least-varied-sets L        Number of least varied sets to generate (default 0)
  -v, --verbose                    Verbose output
  -d, --dont-write                 Don't write to files
  -h, --help                       Print this help
```

A Dummy Staff
==============

So that you can run Lunch Roulette out of the box, I've provided a dummy staff (thanks to Namey for the hilariously fake names) dataset in data/staff.csv


Configuring Lunch Roulette
==========================

At the minimum, Lunch Roulette needs to know how different individual features are from each other. This is achieved by hardcoding a one dimensional mapping in `config/mappings_and_weights.yml`.

Lunch Roulette expects all employees to have a team (Customer Success, Human Resources, etc.).
It is currently assumed that every team only works on a single floor.

Gut Testing Lunch Roulette
==========================

If specified, Lunch Roulette will output the top N results and/or the bottom N results.
This is useful for testing its efficacy: if the bottom sets don't seem as great as the top sets, then you know its working! This will output 2 maximally varied sets, and two minimally varied sets:

```sh
ruby lib/lunch_roulette.rb -v -m 2 -l 2 data/staff.csv
```

If you wanted to get fancy, you could set up a double blind test of these results.

CSV Output
==========

Unless instructed not to, Lunch Roulette will generate a new CSV in data/output each time it is run.
The filenames are unique and based off MD5 hashes of the people in each group of the set.
Lunch Roulette will also output a new staff CSV (prefixed staff_ in data/output) complete with new lunch IDs per-staff so that the next time it is run, it will avoid generating similar lunch groups.
It is recommended that you overwrite data/staff.csv with whatever version you end up going with.
If used with the verbose option, Lunch Roulette will dump a CSV list of staff with their new lunches so you can paste that back into Google Docs (pasting CSVs with commas doesn't seem to work).

Bamboo HR Input
===============

If you have access to Bamboo HR, you can download the [Employee Directory](https://appfolio.bamboohr.com/employees/directory.php)

and run this script:

```sh
ruby script/bamboo_hr_data.rb -v data/Employees.html data/santa_barbara_staff.csv
```

This should take the downloaded Bamboo HR page as input and produce a CSV file `data/santa_barbara_staff.csv`

NOTE: Currently the start date is not available in Bamboo HR, so the current date is used instead.

Learn More & Math
=================
Learn more about Lunch Roulette and the math behind it here:

[Lunch Roulette](https://www.kickstarter.com/backing-and-hacking/lunch-roulette)

