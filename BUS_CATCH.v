module BUS_CATCH #(
  parameter _ADD = 32'h0,
  parameter _BYTE = 'd4
)(
  input io_clk,
  input [3:0]  io_wen,
  input [31:0] io_addr,
  input [31:0] io_din,

  output [(_BYTE * 8) - 1 :0] io_dout
);

  reg [7:0] ram8 [0:(_BYTE-1)];
  integer j;
  initial begin : forSim
    for (j = 0; j<_BYTE; j=j+1) begin
      ram8[j] = 'd0;
    end
  end

  wire addrCatch = (io_addr[31:2]) == _ADD[31:2];

  genvar i;
  generate
    for(i=0; i<_BYTE; i=i+1) begin : ram
      always @ (posedge io_clk) begin
        ram8[i] <= io_wen[i] & addrCatch ? io_din[ (i*8) +: 8] : ram8[i];
      end
      assign io_dout[i*8 +: 8] = ram8[i];
    end
  endgenerate

endmodule
