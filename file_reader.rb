module FileReader

  require 'csv'
  require 'pp'

  def self.create_new_table(data_set)
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

  data = CSV.read('test_data/ags_test_small.txt')
  tables = {}
  table_borders = data.each_index.select { |i| data[i] == [] }
  table_borders.push(data.size)
  p table_borders
  table_borders.each_with_index do |border, index|
    if index == 0
      start = 0
      rows = border
    else
      start = table_borders[index-1] + 1
      rows = border - start
    end
    tables.merge! create_new_table(data[start, rows])
  end
  pp tables
  tables[:abbr][:data].each { |code| p code[1] }

end
