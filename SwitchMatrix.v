module SwitchMatrix (
  input io_mainTrigger,
  input [7:0] io_first,
  input [(8 * 8) - 1:0] io_switchLayerEnd,
  input [(8 * 8) - 1:0] io_switchTriggerDelay,
  input [(8 * 8) - 1:0] io_switchFbDelay,
  input [(8 * 8) - 1:0] io_switchFallbackCatch,

  input [7:0] io_LayerEnd,
  input [7:0] io_LayerLast,
  input [(8*8)-1:0] io_LayerCfg,
  input [7:0] io_TriggerDelay,
  input [7:0] io_FbDelay,
  input [7:0] io_FallbackCatch,

  output [7:0] io_BaseLayer,
  output [7:0] io_switchEnLogic,

  output [7:0] io_pulseEn
);

  wire [7:0] DelayWire;
  wire [7:0] FbDelayWire;
  wire [7:0] FbWire;
  wire [7:0] LEWire;
  wire [7:0] EnWire;

  assign io_switchEnLogic = EnWire;

  genvar i;
  generate
    for(i=0; i<8; i=i+1) begin : Switch
      assign io_pulseEn[i] = (  (io_mainTrigger & io_first[i]) |

                                (
                                  ( (!io_LayerLast[0] & io_LayerCfg[0 * 8 + i]) & EnWire[i] ) |
                                  ( (!io_LayerLast[1] & io_LayerCfg[1 * 8 + i]) & EnWire[i] ) |
                                  ( (!io_LayerLast[2] & io_LayerCfg[2 * 8 + i]) & EnWire[i] ) |
                                  ( (!io_LayerLast[3] & io_LayerCfg[3 * 8 + i]) & EnWire[i] ) |
                                  ( (!io_LayerLast[4] & io_LayerCfg[4 * 8 + i]) & EnWire[i] ) |
                                  ( (!io_LayerLast[5] & io_LayerCfg[5 * 8 + i]) & EnWire[i] ) |
                                  ( (!io_LayerLast[6] & io_LayerCfg[6 * 8 + i]) & EnWire[i] ) |
                                  ( (!io_LayerLast[7] & io_LayerCfg[7 * 8 + i]) & EnWire[i] )
                                )
                              );

      assign EnWire[i] = DelayWire[i] | FbDelayWire[i] | FbWire[i] | LEWire[i];

      assign DelayWire[i] = ( (io_TriggerDelay[0] & io_switchTriggerDelay[0 * 8 + i]) |
                              (io_TriggerDelay[1] & io_switchTriggerDelay[1 * 8 + i]) |
                              (io_TriggerDelay[2] & io_switchTriggerDelay[2 * 8 + i]) |
                              (io_TriggerDelay[3] & io_switchTriggerDelay[3 * 8 + i]) |
                              (io_TriggerDelay[4] & io_switchTriggerDelay[4 * 8 + i]) |
                              (io_TriggerDelay[5] & io_switchTriggerDelay[5 * 8 + i]) |
                              (io_TriggerDelay[6] & io_switchTriggerDelay[6 * 8 + i]) |
                              (io_TriggerDelay[7] & io_switchTriggerDelay[7 * 8 + i]) );

      assign FbDelayWire[i] = ( (io_FbDelay[0] & io_switchFbDelay[0 * 8 + i]) |
                                (io_FbDelay[1] & io_switchFbDelay[1 * 8 + i]) |
                                (io_FbDelay[2] & io_switchFbDelay[2 * 8 + i]) |
                                (io_FbDelay[3] & io_switchFbDelay[3 * 8 + i]) |
                                (io_FbDelay[4] & io_switchFbDelay[4 * 8 + i]) |
                                (io_FbDelay[5] & io_switchFbDelay[5 * 8 + i]) |
                                (io_FbDelay[6] & io_switchFbDelay[6 * 8 + i]) |
                                (io_FbDelay[7] & io_switchFbDelay[7 * 8 + i]) );

      assign FbWire[i] = (  (io_FallbackCatch[0] & io_switchFallbackCatch[0 * 8 + i]) |
                            (io_FallbackCatch[1] & io_switchFallbackCatch[1 * 8 + i]) |
                            (io_FallbackCatch[2] & io_switchFallbackCatch[2 * 8 + i]) |
                            (io_FallbackCatch[3] & io_switchFallbackCatch[3 * 8 + i]) |
                            (io_FallbackCatch[4] & io_switchFallbackCatch[4 * 8 + i]) |
                            (io_FallbackCatch[5] & io_switchFallbackCatch[5 * 8 + i]) |
                            (io_FallbackCatch[6] & io_switchFallbackCatch[6 * 8 + i]) |
                            (io_FallbackCatch[7] & io_switchFallbackCatch[7 * 8 + i]));

      assign LEWire[i] = (  (io_LayerEnd[0] & io_switchLayerEnd[0 * 8 + i]) |
                            (io_LayerEnd[1] & io_switchLayerEnd[1 * 8 + i]) |
                            (io_LayerEnd[2] & io_switchLayerEnd[2 * 8 + i]) |
                            (io_LayerEnd[3] & io_switchLayerEnd[3 * 8 + i]) |
                            (io_LayerEnd[4] & io_switchLayerEnd[4 * 8 + i]) |
                            (io_LayerEnd[5] & io_switchLayerEnd[5 * 8 + i]) |
                            (io_LayerEnd[6] & io_switchLayerEnd[6 * 8 + i]) |
                            (io_LayerEnd[7] & io_switchLayerEnd[7 * 8 + i]));

      assign io_BaseLayer[i] = |(io_first & io_LayerCfg[8*i +: 8]);
    end
  endgenerate  /*Switch*/

endmodule
