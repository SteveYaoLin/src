module LogicRepeat (
  input io_clk,
  input io_rst,
  input [15:0] io_rptNo,
  input [23:0] io_rptTime,

  input io_logicEnd,
  output io_rptEn,
  input io_mainTrigger,
  output reg  io_logicBusy
);
  reg [23:0] timingCnt = 0;
  reg [15:0] rptCnt = 0;

  reg flag = 0;
  always @(posedge io_clk or posedge io_rst) begin
    if(io_rst) begin
      flag      <= 0;
      timingCnt <= 0;
      rptCnt    <= 0;
    end
    else if (io_rptNo != 'd0)begin
      if (io_logicEnd) begin
        flag   <= rptCnt != io_rptNo -1 ? 1'd1 : 1'd0;
        rptCnt <= rptCnt == io_rptNo ?  'd0 : rptCnt + 1'd1;
      end
      else begin
        flag      <= timingCnt == io_rptTime - 1'd1 ? 1'd0 : flag;
        timingCnt <= flag ? timingCnt + 1'd1 :'d0;
      end
    end
    else begin
      flag      <= 0;
      timingCnt <= 0;
      rptCnt    <= 0;
    end
  end

  always @(posedge io_clk or posedge io_rst) begin
    if (io_rst) begin
      io_logicBusy <= 0;
    end
    else begin
      if(io_mainTrigger)
        io_logicBusy <= 1'd1;
      else if(io_logicEnd)
        io_logicBusy <= (|io_rptNo & rptCnt == io_rptNo - 1'd1) | !(|io_rptNo) ?
                          1'd0
                        :
                          io_logicBusy;
      else 
        io_logicBusy <= io_logicBusy;
    end 
  end

  assign io_rptEn = timingCnt == io_rptTime - 1'd1;

endmodule
