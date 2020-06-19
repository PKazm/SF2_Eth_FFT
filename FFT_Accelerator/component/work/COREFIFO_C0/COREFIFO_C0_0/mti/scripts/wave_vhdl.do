onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/wclk
add wave -noupdate /testbench/we
add wave -noupdate /testbench/wdata
add wave -noupdate /testbench/full
add wave -noupdate /testbench/afull
add wave -noupdate /testbench/rclk
add wave -noupdate /testbench/re
add wave -noupdate /testbench/rdata
add wave -noupdate /testbench/empty
add wave -noupdate /testbench/aempty
add wave -noupdate /testbench/clk
add wave -noupdate /testbench/ext_waddr
add wave -noupdate /testbench/ext_raddr
add wave -noupdate /testbench/ext_data
add wave -noupdate /testbench/ext_rd
add wave -noupdate /testbench/ext_we
add wave -noupdate /testbench/ext_re
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {47074657 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 524
configure wave -valuecolwidth 60
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits fs
update
WaveRestoreZoom {0 ps} {53716822 ps}
