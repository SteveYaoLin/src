module MC_Ctrl (
  input io_clk,
  input io_rst,

  input io_catch,

  input [15:0] io_RptNo,
  input [5:0]  portNo, //端口数;

  output reg [5:0] ctrl = 0
);

  reg [1:0] sta = 0;
  reg [15:0] rptCnt = 0;

  always @ (posedge io_clk or posedge io_rst) begin
    if (io_rst) begin
      sta <= 0;
      rptCnt <= 0;
      ctrl <= 0;
    end
    else begin
      case (sta)
        0 : begin
          rptCnt <= 0;
          if (io_catch) begin
            sta <= 6'd1;
            ctrl <= 6'd1;
          end
          else begin
            sta <= 2'd0;
            ctrl <= 6'd0;
          end
        end
        1 : begin
          rptCnt <= !(|io_RptNo) | (rptCnt == io_RptNo) ? 16'd1 : rptCnt + 1'd1;
          sta <= 2'd2;
        end
        2 : begin
          sta <= io_catch ? 2'd1 : 2'd2;
          ctrl <= io_catch ?
                    !(|io_RptNo) | (rptCnt == io_RptNo) ?
                      ctrl == portNo ? 6'd1 : ctrl + 1'd1
                    :
                      ctrl
                  :ctrl;
        end
        default: sta <= 2'd0;
      endcase
    end
  end

endmodule
