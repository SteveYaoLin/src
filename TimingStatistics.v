module TimingStatistics #(
  parameter _RAM_WIDTH = 32
)(
  input io_clk,
  input io_rst,

  input io_fbCatchIn,

  input  [_RAM_WIDTH - 1:0] io_timingIn,
  output [_RAM_WIDTH - 1:0] io_timing1st,
  output [_RAM_WIDTH - 1:0] io_timingMax,
  output [_RAM_WIDTH - 1:0] io_timingMin
);

  reg [_RAM_WIDTH - 1:0] ram_Max = 0;
  reg [_RAM_WIDTH - 1:0] ram_1st = 0;
  reg [_RAM_WIDTH - 1:0] ram_Min = ~32'd0;

  always @ (posedge io_clk or posedge io_rst) begin
    if (io_rst) begin
      ram_Max <= 0;
      ram_1st <= 0;
      ram_Min <= ~32'd0;
    end
    else begin
      if (io_fbCatchIn) begin
        ram_Max <= ram_Max < io_timingIn ? io_timingIn : ram_Max;
        ram_1st <= |ram_1st ? ram_1st : io_timingIn;
        ram_Min <= ram_Min > io_timingIn ? io_timingIn : ram_Min;
      end
      else begin
        ram_Max <= ram_Max;
        ram_1st <= ram_1st;
        ram_Min <= ram_Min;
      end
    end
  end

  assign io_timing1st = ram_1st;
  assign io_timingMax = ram_Max;
  assign io_timingMin = ram_Min;

endmodule
