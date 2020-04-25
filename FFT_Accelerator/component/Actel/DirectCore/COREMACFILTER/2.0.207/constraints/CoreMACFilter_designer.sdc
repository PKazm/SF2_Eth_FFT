# 125 MHZ period
set period8  8.0

# 62.5 MHZ period
set period10  16.0

# 50 MHZ period
set period20  20.0

create_clock  -period $period8   { RXCLK }
create_clock  -period $period10  { PMA_RX_CLK0 }
create_clock  -period $period20  { PCLK }

