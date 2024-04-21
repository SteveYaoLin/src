module Timing #(
  parameter _RAM_WIDTH = 32
)(
  input io_clk,

  input io_pulsePort,
  input io_fbCatch,

  input io_defaultLevel_Pulse,

  output [_RAM_WIDTH - 1:0] io_timing

);

  reg pulsePort_d;
  reg pulsePort_d1;
  // reg fbCatch_d;
  reg [_RAM_WIDTH - 1:0] cntTiming = 0;
  reg flagBusy = 0;
  wire pulseRising = (io_pulsePort ^ io_defaultLevel_Pulse) & (pulsePort_d ^ io_defaultLevel_Pulse) & !(pulsePort_d1 ^ io_defaultLevel_Pulse);
  wire Timing_clr = (io_pulsePort ^ io_defaultLevel_Pulse) & !(pulsePort_d ^ io_defaultLevel_Pulse);
  always @ (posedge io_clk) begin : fd
    pulsePort_d <= io_pulsePort;
    pulsePort_d1 <= pulsePort_d;
    // fbCatch_d <= io_fbCatch;
  end

  always @ (posedge io_clk) begin
    flagBusy <= Timing_clr ? 1'b0 :
                pulseRising ? 1'b1 :
                io_fbCatch ? 1'b0 :
                flagBusy;
  end

  always @ (posedge io_clk) begin : timing
    cntTiming <=  Timing_clr ? 0:
                  flagBusy ?
                    cntTiming + 1'b1
                  : pulseRising ? 1'b1
                  : cntTiming;
  end

  assign io_timing = cntTiming;

endmodule
