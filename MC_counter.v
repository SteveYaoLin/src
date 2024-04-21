module MC_Counter(
  input io_clk,
  input io_rst,
  input io_mainEN,
  input io_catch,
  input io_fbEn,
  input [5:0] ctrl,

  output [15:0] io_catchCounter,
  output [15:0] io_fbCounter,
  output [(16*32)-1:0] io_outCounter
);

  reg catch_d = 0;
  reg fbEn_d1 = 0;
  reg catch_d2 = 0;
  reg fbEn_d2 = 0;
  reg mainEN_d = 0 ;
  reg mainEN_d2 = 0 ;
  always @ (posedge io_clk) mainEN_d <= io_mainEN;
  always @ (posedge io_clk) mainEN_d2 <= mainEN_d;
  always @ (posedge io_clk) catch_d <= io_catch;
  always @ (posedge io_clk) catch_d2 <= catch_d;
  always @ (posedge io_clk) fbEn_d1 <= io_fbEn;
  always @ (posedge io_clk) fbEn_d2 <= fbEn_d1;
  reg [15:0]        catchCounter = 0;
  reg [15:0]        fbCounter = 0;
  reg [(16*32)-1:0] outCounter = {(16*32){1'd0}};
  integer i = 0;

  assign io_catchCounter = catchCounter;
  assign io_fbCounter = fbCounter;
  assign io_outCounter = outCounter;

  always @ (posedge io_clk or posedge io_rst) begin
    if (io_rst) begin
      catchCounter <= 0;
      fbCounter    <= 0;
      outCounter   <= {(16*32){1'd0}};
    end
    else begin
      //catchCounter <= !io_catch | &catchCounter ? catchCounter :catchCounter + 1'd1;
      //fbCounter    <= !io_fbEn  | &fbCounter    ? fbCounter    :fbCounter    + 1'd1;
      catchCounter <= (!(catch_d && !catch_d2) | &catchCounter )? catchCounter :catchCounter + 1'd1;
      fbCounter    <=( !(fbEn_d1 && !fbEn_d2)  | &fbCounter    )? fbCounter    :fbCounter    + 1'd1;
      for (i=0;i<32;i=i+1) begin
        outCounter[i*16 +: 16] <= !((mainEN_d & !mainEN_d2) & (i == ctrl - 1)) | (&outCounter[i*16 +:16]) | !(|ctrl) ?
                                    outCounter[i*16 +:16]
                                  : outCounter[i*16 +:16] + 1'd1;
      end
    end
  end

endmodule
