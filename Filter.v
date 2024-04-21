module Filter #(
  parameter _RAM_WIDTH = 32
)(
  input io_clk,
  input io_rst,
  input io_in,
  output io_out,

  input [_RAM_WIDTH - 1:0] io_filterCnt
);

  reg signalClean = 0;
  reg [_RAM_WIDTH - 1:0] count = 0;
  reg signalIn_d = 0;

  always @ (posedge io_clk) begin : fd
    signalIn_d <= io_in;
  end

  always @ (posedge io_clk ) begin : filter
    if (io_rst) begin
      count <= 0;
      signalClean <= signalIn_d;
    end
    else begin
      count <= (io_in ^ signalIn_d) ? io_filterCnt - 1 : |count ? count - 1'b1 : count;
      signalClean <= (count == 0) ? signalIn_d : signalClean;
    end
  end

  assign io_out = signalClean;

endmodule
