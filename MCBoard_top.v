
module MCBoard_top(
  input io_clk,
  input io_rst_n,

  inout io_SPI_SDI,
  inout io_SPI_SDO,
  inout io_SPI_SCK,
  inout io_SPI_SS,

  input  io_UART_RX,
  output io_UART_TX,
  input  io_UART_RX0,
  output io_UART_TX0,
  
  input   io_trigDriv,  //触发驱动接口
  output  io_fb,  //触发驱动接口
  output [31:0] io_follow_led ,
  output [31:0] io_outPort  //同步触发接口

);
  wire CLK_80M; //MB主时钟
  wire CLK_10M;
  wire RST;  // MB 复位模块输出 rst
  wire ClkGen_LOCKED;

  //wire [7:0]  MB_GPIO_IO;
  wire [7:0]  MB_GPIO_O;
  //wire [7:0]  MB_GPIO_T;
  wire        MB_BRAM_Rst_pin;
  wire        MB_BRAM_Clk_pin;
  wire        MB_BRAM_EN_pin;
  wire [3:0]  MB_BRAM_WEN_pin;
  wire [31:0] MB_BRAM_Addr_pin;
  wire [31:0] MB_BRAM_Din_pin;
  wire [31:0] MB_BRAM_Dout_pin;

  reg [6:0] logicRst_80M;
  reg [6:0] ramRst_80M;
  reg [5:0] logicRst_10M;
  reg [5:0] ramRst_10M;
  always @ (posedge CLK_80M) begin
    logicRst_80M <= {logicRst_80M[5:0],MB_GPIO_O[0]};
    ramRst_80M   <= {ramRst_80M[5:0]  ,MB_GPIO_O[1]};
  end
  always @ (posedge CLK_10M) begin
    logicRst_10M <= {logicRst_10M[4:0],|logicRst_80M};
    ramRst_10M   <= {ramRst_10M[4:0]  ,|ramRst_80M};
  end

  MultiChannel_LogicTop MultiChannel_LogicTop(
    .io_clk     (CLK_10M),
    .io_rst     (RST | (|logicRst_10M)),
    .io_rst_ram (RST | (|ramRst_10M)),

    //BUS
    .BUS_CLK      (MB_BRAM_Clk_pin),
    .BUS_ADDR     ({20'd0,MB_BRAM_Addr_pin[0 +: 4*3]}),//(MB_BRAM_Addr_pin),
    .BUS_BE       (MB_BRAM_WEN_pin),
    .BUS_DATA_WR  (MB_BRAM_Dout_pin),
    .BUS_DATA_RD  (MB_BRAM_Din_pin),

    .io_pulseIn   (~io_trigDriv),
    .io_fbOut     (io_fb),
    .io_follow_led (io_follow_led),
    .io_Out       (io_outPort)

  );

  MbCore_top MicroBlazeCore(
    .SYS_CLK_80M    ( CLK_80M       ),
    .SYS_CLK_LOCKED ( ClkGen_LOCKED ),
    .SYS_RST_N      ( io_rst_n      ),
    .Peripheral_rst ( RST           ),

    .UART_RX        ( io_UART_RX    ),
    .UART_TX        ( io_UART_TX    ),
    .xps_uartlite_0_RX_pin        ( io_UART_RX0 ),
    .xps_uartlite_0_TX_pin        ( io_UART_TX0 ),
    .SPI_SS         ( io_SPI_SS     ),
    .SPI_SCK        ( io_SPI_SCK    ),
    .SPI_MISO       ( io_SPI_SDO    ),
    .SPI_MOSI       ( io_SPI_SDI    ),

    //.Generic_GPIO_GPIO_IO_pin   ( MB_GPIO_IO ),
    //.Generic_GPIO_GPIO_IO_T_pin ( MB_GPIO_T ),
    .Generic_GPIO_GPIO_IO_O_pin ( MB_GPIO_O ),

    .PLB2BRAM_BRAM_Rst_pin  ( MB_BRAM_Rst_pin  ),
    .PLB2BRAM_BRAM_Clk_pin  ( MB_BRAM_Clk_pin  ),
    .PLB2BRAM_BRAM_EN_pin   ( MB_BRAM_EN_pin   ),
    .PLB2BRAM_BRAM_WEN_pin  ({MB_BRAM_WEN_pin[0],
                              MB_BRAM_WEN_pin[1],
                              MB_BRAM_WEN_pin[2],
                              MB_BRAM_WEN_pin[3]}),
    .PLB2BRAM_BRAM_Addr_pin ( MB_BRAM_Addr_pin ),
    .PLB2BRAM_BRAM_Din_pin  ( MB_BRAM_Din_pin  ),
    .PLB2BRAM_BRAM_Dout_pin ( {MB_BRAM_Dout_pin[8*0 +: 8]
                              ,MB_BRAM_Dout_pin[8*1 +: 8]
                              ,MB_BRAM_Dout_pin[8*2 +: 8]
                              ,MB_BRAM_Dout_pin[8*3 +: 8]}  )
  );

  CLOCK_GEN ClkGen (
    // Clock in ports
    .CLK_IN1 ( io_clk        ),      // IN
    // Clock out ports
    .CLK_OUT1( CLK_80M       ),     // OUT
    .CLK_OUT2( CLK_10M       ),     // OUT
    // Status and control signals
    .RESET   ( !io_rst_n     ),// IN
    .LOCKED  ( ClkGen_LOCKED )     // OUT
  );


endmodule
