#!/usr/bin/env ruby

module AGS

  require 'csv'
  require 'pp'

  # Read the GROUP attributes and create a hash of data arrays
  def self.create_new_group(data_set)
    if data_set == []
      return {}
    else
      table = {}
      group_title = data_set.assoc("GROUP").last.downcase.to_sym
      group = table[group_title] = {}
      data_set.shift
      data_set.each_with_index do |row, index|
        key = row.first.downcase.to_sym
        row.shift
        if key == :data
          group[key] ||= []
          group[key].push row
        else
          group[key] = row
        end
      end
      table
    end
  end

  # Read the whole file, find and separate all groups as tables
  def self.parse(file)
    data = CSV.read(file)
    tables = {}
    table_borders = data.each_index.select { |i| data[i] == [] }
    table_borders.push(data.size)
    table_borders.each_with_index do |border, index|
      if index == 0
        start = 0
        rows = border
      else
        start = table_borders[index-1] + 1
        rows = border - start
      end
      # Add the new table hash to the hash (dict structure) of all tables
      tables.merge! create_new_group(data[start, rows])
    end
    tables
  end

  # Parse a file and save it in an object for further processing
  DATA_FILE = 'test_data/Example_AGS_file.txt'.freeze
  ags_data = parse(DATA_FILE)

  # EXAMPLE to demonstrate the easy access via script without Database
  #
  # USE CASE: Search the data object for a specific data subset,
  # entered as arguments when called. Syntax:
  # ./ags.rb <GROUP> <HEADING> <Search String> <HEADING_OF_OUTPUT_VALUE>
  #
  # For example:
  # ./ags.rb dcpt loca_id WS05 dcpg_dpth

  # Argument 0: GROUP name (lowercase)
  group_name = ARGV[0].to_sym
  # Argument 1: HEADING name (lowercase or uppercase)
  heading_search = ARGV[1].upcase
  # Argument 2: Search string (full text, also partials)
  search_term = ARGV[2]
  # Argument 4: HEADING name of the desired value
  heading_target = ARGV[3].upcase

  # select the group
  group = ags_data[group_name]
  # get the column numbers
  search_column = group[:heading].index(heading_search)
  target_column = group[:heading].index(heading_target) || 0

  # Select all rows in which the column entry matches the search string,
  # the result set is an array of row arrays containing strings.
  result_set = group[:data].select { |row| row[search_column].include?(search_term) }

  # TODO: Export csv sets like result_set.map { |row| row.to_csv } # (&:to_csv)

  # Print search result in a nice way:
  puts "No.  #{group[:heading]}, #{heading_target}"
  result_set.each_with_index do |row, index|
    puts "#{'%03d' % index}: #{row}, #{row[target_column]}"
  end

end
