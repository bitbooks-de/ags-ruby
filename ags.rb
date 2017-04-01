module AGS

  require 'csv'
  require 'pp'

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
      tables.merge! create_new_group(data[start, rows])
    end
    tables
  end

  # Parse a file and save it in an object
  test = parse('test_data/Example_AGS_file.txt')

  # Search the object for a specific data subset
  search_result = test[:abbr][:data].select {
    |row| row[2].include?('carbon')
  }

  # Print search result array
  pp search_result

end
