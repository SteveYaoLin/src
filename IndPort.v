module IndPort #(
  parameter _RAM_WIDTH = 32
) (
  input io_clk,
  input io_rst,
  input io_rst_ram,

  input io_pulseEn,

  input io_defaultLevel,
  input [_RAM_WIDTH - 1:0] io_pulseWidth,
  input [_RAM_WIDTH - 1:0] io_trigDelay,
  input [16 - 1:0] io_repeatCnt,

  output io_pulseOut,
  output ind_led,
  output [16 - 1:0] ActCounter
);

  reg [_RAM_WIDTH - 1:0] repeatCnt = 0;
  
  reg [_RAM_WIDTH - 1:0] ind_led_cnt;
  wire delayEnd;
  wire pulseEn;
  reg  pulseEn_d1;
  reg en_r = 1'd0;
  always @(posedge io_clk) en_r <= io_pulseEn;

  always @(posedge io_clk) begin
    if (io_rst) begin
      repeatCnt <= (|io_repeatCnt) ? io_repeatCnt - 1'd1 : io_repeatCnt;
    end
    else begin
      repeatCnt <=  delayEnd ?
                      (|repeatCnt) ? repeatCnt - 'd1 : repeatCnt
                    : repeatCnt;
    end
  end

  assign pulseEn = (io_pulseEn & !en_r) | ((|repeatCnt) & (delayEnd));
  always @(posedge io_clk) pulseEn_d1 <= pulseEn;
    
  //end
  always @(posedge io_clk or posedge io_rst_ram ) begin
    if (io_rst_ram) begin
      ind_led_cnt <= 'd0;
    end 
    else if (!pulseEn & pulseEn_d1)  begin
      ind_led_cnt <= io_pulseWidth + 'd500;
    end
    else begin
      ind_led_cnt <= (~|ind_led_cnt) ? ind_led_cnt : (ind_led_cnt^io_defaultLevel) ? ind_led_cnt + 1'd1 : ind_led_cnt - 1'd1;
    end
    
  end
  assign ind_led = (~|ind_led_cnt) ? 1'b1 : 1'b0;
  reg [15:0] Counter = 'd0;  //触发驱动 计数

  always @(posedge io_clk or posedge io_rst_ram) begin
    if (io_rst_ram) begin
      Counter <= 'd0;
    end else begin
      Counter <= pulseEn ? &Counter ? ~16'd0 : Counter + 1'd1 : Counter;
    end
  end

  assign ActCounter = Counter;

  PulseGen #(
    (_RAM_WIDTH)
  ) IndPulseGen (
    .io_clk            ( io_clk           ),
    .io_rst            ( io_rst           ),

    .io_en             ( pulseEn          ),

    .io_pulseOut       (io_pulseOut       ),
    .io_delayOut       (delayEnd          ),

    .io_defaultLevel   ( io_defaultLevel  ),
    .io_pulseWidth     ( io_pulseWidth    ),
    .io_trigDelay      ( io_trigDelay     )
  );


endmodule
