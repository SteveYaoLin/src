/**
* 触发脉冲宽度: 1us ~ 1s可设置
* 触发电平极性:可设置(高/低电平)
* 触发延迟:1us ~ 1s可设置
*
*/

module PulseGen #(
  parameter _RAM_WIDTH = 32
)(
  input io_clk,
  input io_rst,

  input io_en,

  output io_pulseOut,
  output io_delayOut,

  input io_defaultLevel,
  input [_RAM_WIDTH - 1:0] io_pulseWidth,
  input [_RAM_WIDTH - 1:0] io_trigDelay
);

  reg [_RAM_WIDTH - 1:0] cnt_delay = 0;
  reg [_RAM_WIDTH - 1:0] cnt_pulseWidth = 0;

  always @ (posedge io_clk or posedge io_rst) begin
    if(io_rst)begin
      cnt_delay <= 0;
      cnt_pulseWidth <= 0;
    end
    else if (io_en )begin
      cnt_delay <= io_trigDelay;
      cnt_pulseWidth <= io_pulseWidth;
    end
    else begin
      cnt_delay <= |cnt_delay ? cnt_delay - 1'd1:cnt_delay;
      cnt_pulseWidth <= |cnt_pulseWidth ? cnt_pulseWidth - 1'd1 : cnt_pulseWidth;
    end
  end

  reg delay_d;
  always @ (posedge io_clk) begin
    delay_d <= cnt_delay[0];
  end

  assign io_pulseOut = ~(cnt_pulseWidth == 0) ^ io_defaultLevel;
  assign io_delayOut = (cnt_delay == 0) & delay_d;

endmodule
