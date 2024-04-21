module SyncPort#(
  parameter _RAM_WIDTH        = 32,
  parameter _RAM_WIDTH_TIMING = 32
) (
  input io_clk,
  input io_rst,
  input io_rst_ram,

  //Triger Port
  input  io_pulseEn,
  output io_pulseOut,
  output io_delayOut,
  input  [_RAM_WIDTH - 1:0] io_pulseWidth,
  input  [_RAM_WIDTH - 1:0] io_trigDelay,
  input  io_pulseDefLev,
  output   follow_led,

  //Fallback Port
  input  io_fbIn,
  output io_fbCatch,
  input  [_RAM_WIDTH - 1:0] io_fbFilterCnt,
  input  io_fbDefLev,
  // Fallback delay Port
  input [_RAM_WIDTH - 1:0] io_Fb_DelayCnt,
  input io_Fb_en,
  output  io_Fb_DelayEnd,
  //Timing
  input   work_End ,
  output [_RAM_WIDTH_TIMING - 1:0] io_timing1st,
  output [_RAM_WIDTH_TIMING - 1:0] io_timingMax,
  output [_RAM_WIDTH_TIMING - 1:0] io_timingMin,

  //Counter
  
  output [15:0] io_pulseCounter,
  output [15:0] io_fbCounter
);

  reg [15:0] pulseCounter = 'd0;
  reg [15:0] fbCounter    = 'd0;
  reg pulseEn_d1 ;
  reg pulseEn_d2 ;
  reg fbCatch_d1;
  reg fbCatch_d2;
  assign io_pulseCounter = pulseCounter;
  assign io_fbCounter    = fbCounter;
  reg [_RAM_WIDTH - 1:0] follow_led_cnt;
  //wire follow_led ;
  always @(posedge io_clk ) begin
    pulseEn_d1 <= io_pulseEn ;
    pulseEn_d2 <= pulseEn_d1 ;
    fbCatch_d1 <= io_fbCatch;
    fbCatch_d2 <= fbCatch_d1;
  end
  always @(posedge io_clk or posedge io_rst_ram) begin
    if (io_rst_ram)begin
      follow_led_cnt <= 'd0;
    end
    else if (!pulseEn_d1 & pulseEn_d2) begin
      follow_led_cnt <=  io_pulseWidth + 'd500;
    end
    else  begin
      follow_led_cnt <= (~|follow_led_cnt)? follow_led_cnt:(io_pulseOut^io_pulseDefLev) ? follow_led_cnt + 1'b1: follow_led_cnt -'b1 ;
    end 
      
    //end
  end
  assign follow_led = (~|follow_led_cnt)? 1'b0 : 1'b1;
  always @(posedge io_clk or posedge io_rst_ram) begin
    if (io_rst_ram) begin
      pulseCounter <= 'd0;
      fbCounter    <= 'd0;
    end else begin
      pulseCounter <= (pulseEn_d1 & !pulseEn_d2) ? &pulseCounter ? ~16'd0 : pulseCounter + 1'd1 : pulseCounter;
      fbCounter    <= (fbCatch_d1 & !fbCatch_d2) ? &fbCounter    ? ~16'd0 : fbCounter    + 1'd1 : fbCounter   ;
    end
  end
  
  wire timing_end ;

  PulseGen #(._RAM_WIDTH(_RAM_WIDTH)) FbDelay(
    .io_clk         (io_clk),
    .io_rst         (io_rst),
    .io_trigDelay   (io_Fb_DelayCnt),
    .io_en          (io_Fb_en),
    .io_delayOut    (io_Fb_DelayEnd)
  );
  assign timing_end = (|io_Fb_DelayCnt) ?  io_Fb_DelayEnd : io_fbCatch ;

  PulseGen #(
    ._RAM_WIDTH (_RAM_WIDTH)
  ) TriggerPort (
    .io_clk  (io_clk),
    .io_rst  (io_rst),

    .io_en   ( io_pulseEn ),

    .io_pulseOut     (io_pulseOut    ),
    .io_delayOut     (io_delayOut    ),

    .io_defaultLevel (io_pulseDefLev ),
    .io_pulseWidth   (io_pulseWidth  ),
    .io_trigDelay    (io_trigDelay   )
  );

  PulseCatch #(
    ._RAM_WIDTH       (_RAM_WIDTH)
  ) FallbackPort (
    .io_clk           (io_clk            ),
    .io_rst           (io_rst            ),
    .io_fb_in         (io_fbIn           ),
    .io_fb_catch      (io_fbCatch        ),

    .io_filterCnt     (io_fbFilterCnt),
    .io_defaultLevel  (io_fbDefLev)
  );

  wire [_RAM_WIDTH_TIMING -1 :0] timing;
  Timing #(
    ._RAM_WIDTH (_RAM_WIDTH_TIMING)
  ) Timing (
    .io_clk                (io_clk),

    .io_pulsePort          (io_pulseOut    ),
    .io_fbCatch            (timing_end | work_End),//(io_fbCatch        ),

    .io_defaultLevel_Pulse (io_pulseDefLev ),

    .io_timing             (timing)
  );

  TimingStatistics #(
    ._RAM_WIDTH (_RAM_WIDTH_TIMING)
  ) TimingStatistics (
    .io_clk             (io_clk),
    .io_rst             (io_rst_ram),

    .io_fbCatchIn       (timing_end        ),

    .io_timingIn        (timing),
    .io_timing1st       (io_timing1st),
    .io_timingMax       (io_timingMax),
    .io_timingMin       (io_timingMin)
  );

endmodule
