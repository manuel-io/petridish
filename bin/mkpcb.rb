#!/usr/bin/env ruby

require 'optparse'

modifiers = {
  name: '',
  width: 100,   # mm
  height: 100,  # mm
  spacing: 2.54 # mm
}

OptionParser.new do |opts|
  opts.banner = "Usage: #{File.basename($0)} [options]"

  opts.on('-x', '--width value', Integer, 'Set PCB width [mm]') do |value|
    modifiers[:width] = value.to_i
  end

  opts.on('-y', '--height value', Integer, 'Set PCM height [mm]') do |value|
    modifiers[:height] = value.to_i
  end

  opts.on('-s', '--spacing value', Float, 'Set PCM spacing [mm]') do |value|
    modifiers[:spacing] = value.to_f
  end

  opts.on('-h', '--help', 'Prints this help') do
    puts opts
    exit
  end

end.parse!

Width = modifiers[:width] * 39.3700787402
Height = modifiers[:height] * 39.3700787402
Spacing = modifiers[:spacing] * 39.3700787402

Rows = Height / Spacing
Cols = Width / Spacing

puts <<-BLOX
FileVersion[20091103]

PCB["#{modifiers[:name]}" #{Width + 100}mil #{Height + 100}mil]

Grid[10000.000000 0.0000 0.0000 0]
PolyArea[3100.006200]
Thermal[0.500000]
DRC[100.00mil 100.00mil 100.00mil 100.00mil 100.00mil 100.00mil]
Flags("nameonpcb,uniquename,clearnew,snappin")
Groups("1,c:2:3:4:5:6,s:7:8")
Styles["Signal,59.06mil,59.06mil,59.06mil,59.06mil:Power,25.00mil,60.00mil,35.00mil,10.00mil:Fat,40.00mil,60.00mil,35.00mil,10.00mil:Skinny,6.00mil,24.02mil,11.81mil,6.00mil"]

Attribute("PCB::grid::unit" "mm")
Attribute("PCB::grid::size" "100.00mil")
BLOX

$stderr.puts "Board: #{modifiers[:width]} x #{modifiers[:height]}"
$stderr.puts "Rows: #{Rows.to_i}"
$stderr.puts "Cols: #{Cols.to_i}"

(1..Cols.to_i).each do |x|
  (1..Rows.to_i).each do |y|
    puts "Via[#{Spacing.to_i * x}.00mil #{Spacing.to_i * y}.00mil 63.06mil 118.12mil 0.0000 59.06mil \"\" \"\"]"
  end
end

puts <<-BLOX
Layer(1 "top")
(
)
Layer(2 "ground")
(
)
Layer(3 "signal2")
(
)
Layer(4 "signal3")
(
)
Layer(5 "power")
(
)
Layer(6 "bottom")
(
)
Layer(7 "outline")
(
)
Layer(8 "spare")
(
)
Layer(9 "silk")
(
)
Layer(10 "silk")
(
)
BLOX
