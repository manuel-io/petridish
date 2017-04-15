#!/usr/bin/env ruby

x = 63.06;
y = 63.06;

puts <<-BLOX
FileVersion[20091103]

PCB["New" 100.0000mm 100.0000mm]

Grid[1000.000000 0.0000 0.0000 1]
PolyArea[3100.006200]
Thermal[0.500000]
DRC[100.00mil 100.00mil 100.00mil 100.00mil 100.00mil 100.00mil]
Flags("nameonpcb,uniquename,clearnew,snappin")
Groups("1,c:2:3:4:5:6,s:7:8")
Styles["Signal,59.06mil,59.06mil,59.06mil,59.06mil:Power,25.00mil,60.00mil,35.00mil,10.00mil:Fat,40.00mil,60.00mil,35.00mil,10.00mil:Skinny,6.00mil,24.02mil,11.81mil,6.00mil"]
BLOX

(1..39).each do
  (1..39).each do
    puts "Via[#{x}mil #{y}mil 63.06mil 118.12mil 0.0000 59.06mil \"\" \"\"]"
    x += 100
  end
  x = 63.06;
  y += 100;
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
