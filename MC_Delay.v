module MC_Delay (
  input io_clk,
  input io_rst,

  input io_catch,
  input [23:0] io_Delay,
  output io_delayEnd
);

  reg [23:0] delayCnt = 0;
  reg flag = 0;

  always @ (posedge io_clk or posedge io_rst) begin
    if (io_rst) begin
      delayCnt <= 0;
      flag <= 0;
    end
    else begin
      delayCnt <= flag ?
                    delayCnt == io_Delay ? 24'd0 : delayCnt + 1'd1
                  : 24'd0;
      flag <= io_catch ? 1'd1 : delayCnt == io_Delay ? 1'd0 : flag;
    end
  end

  assign io_delayEnd = |io_Delay ? delayCnt == io_Delay : io_catch;

endmodule
