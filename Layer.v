module Layer (
  input io_clk,
  input io_rst,
  input [15:0] io_layerCnt,

  input [7:0] io_fbCatch,
  input [7:0] io_delayEnd,
  input [7:0] io_switchEnLogic,

  input [7:0]  io_layerCfg,
  input io_workingMode,
  input io_BaseLayer,

  output io_layerEnd,
  output io_layerLast

);

  // reg [15:0] LayerRepeatNum = 0;
  reg [15:0] LayerCount = 0;
  wire [7:0] triggerSwitch;

  genvar i;
  generate
    for(i=0; i<8; i=i+1) begin:switch
      assign triggerSwitch[i] = io_layerCfg[i] &
                                ( io_workingMode ? io_delayEnd[i] : io_fbCatch[i]);
    end
  endgenerate  /*switch*/

  always @(posedge io_clk or posedge io_rst) begin
    if (io_rst) begin
      // LayerRepeatNum <= |io_layerCnt ? io_layerCnt - 1'd1 : io_layerCnt;
      LayerCount    <= 'd0;
    end
    else begin
      LayerCount <=
                      // io_BaseLayer ?
                      |(io_switchEnLogic & io_layerCfg) ?
                        io_layerLast ? 16'd0 : LayerCount + 1'd1
                      : LayerCount;
                    // : |(triggerSwitch) ?
                    //     io_layerLast ? 16'd0 : LayerCount + 1'd1
                    //   : LayerCount;
      // LayerRepeatNum<= LayerRepeatNum;
    end
  end

  // assign io_layerLast = LayerCount == LayerRepeatNum ;
  assign io_layerLast = |io_layerCnt ?
                          io_BaseLayer ?
                            (LayerCount == io_layerCnt - 1'd1) :
                            (LayerCount == io_layerCnt)
                        : 1'd1;
  assign io_layerEnd  =
                        // io_BaseLayer ?
                          |(io_switchEnLogic & io_layerCfg) & io_layerLast ;
                        // : |(triggerSwitch) & io_layerLast;

endmodule
