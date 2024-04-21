module TestBoardTop (
  input io_CLK,
  input io_RST_N,

  inout io_SPI_SDI,
  inout io_SPI_SD0,
  inout io_SPI_SCK,
  inout io_SPI_SS,

  inout io_LED,
  inout io_KEY,

  input io_UART_RX,
  output io_UART_TX,
  input io_UART_RX_1,
  output io_UART_TX_1
);

  wire ClkGen_LOCKED;
  wire CLK_80M;
  wire CLK_10M;

  CLOCK_GEN ClkGen (
    // Clock in ports
    .CLK_IN1 (io_CLK       ),      // IN
    // Clock out ports
    .CLK_OUT1(CLK_80M      ),     // OUT
    .CLK_OUT2(CLK_10M      ),     // OUT
    // Status and control signals
    .RESET   (!io_RST_N    ),// IN
    .LOCKED  (ClkGen_LOCKED)     // OUT
  );

  wire [7:0] MB_GPIO;
  wire RST;

  // wire PLB2BRAM_BRAM_Rst_pin;
  wire PLB2BRAM_BRAM_Clk_pin;
  wire PLB2BRAM_BRAM_EN_pin;
  wire [3:0] PLB2BRAM_BRAM_WEN_pin;
  wire [31:0] PLB2BRAM_BRAM_Addr_pin;
  wire [31:0] PLB2BRAM_BRAM_Din_pin;
  wire [31:0] PLB2BRAM_BRAM_Dout_pin;


  wire [31:0]  BRAM_ADDR =  {8'd0,PLB2BRAM_BRAM_Addr_pin[0 +: 8*3]};


  MbCore_top MicroBlazeCore(
    .SYS_CLK_80M    ( CLK_80M       ),
    .SYS_CLK_LOCKED ( ClkGen_LOCKED ),
    .SYS_RST_N      ( io_RST_N      ),
    .Peripheral_rst ( RST           ),

    .UART_RX        ( io_UART_RX    ),
    .UART_TX        ( io_UART_TX    ),

    .SPI_SS         ( io_SPI_SS     ),
    .SPI_SCK        ( io_SPI_SCK    ),
    .SPI_MISO       ( io_SPI_SD0    ),
    .SPI_MOSI       ( io_SPI_SDI    ),

    .Generic_GPIO_GPIO_IO_pin          ( {io_LED,io_KEY} ),
    .Generic_GPIO_GPIO_IO_T_pin        (),

    // output PLB2BRAM_BRAM_Rst_pin;
    .PLB2BRAM_BRAM_Clk_pin  ( PLB2BRAM_BRAM_Clk_pin  ),
    .PLB2BRAM_BRAM_EN_pin   ( PLB2BRAM_BRAM_EN_pin   ),
    .PLB2BRAM_BRAM_WEN_pin  ( PLB2BRAM_BRAM_WEN_pin  ),
    .PLB2BRAM_BRAM_Addr_pin ( PLB2BRAM_BRAM_Addr_pin ),
    .PLB2BRAM_BRAM_Din_pin  ( PLB2BRAM_BRAM_Din_pin  ),
    .PLB2BRAM_BRAM_Dout_pin ( PLB2BRAM_BRAM_Dout_pin ),
    .xps_uartlite_0_RX_pin  ( io_UART_RX_1           ),
    .xps_uartlite_0_TX_pin  ( io_UART_TX_1           )
  );

  BRAM_1K your_instance_name (
    .clka     ( PLB2BRAM_BRAM_Clk_pin  ), // input clka
    .ena      ( PLB2BRAM_BRAM_EN_pin   ), // input ena
    .wea      ( PLB2BRAM_BRAM_WEN_pin  ), // input [3 : 0] wea
    .addra    ( BRAM_ADDR ), // input [31 : 0] addra
    .dina     ( PLB2BRAM_BRAM_Dout_pin ), // input [31 : 0] dina
    .douta    ( PLB2BRAM_BRAM_Din_pin  )  // output [31 : 0] douta
  );

endmodule
