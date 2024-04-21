module BUS (
  input io_clk,
  // input io_rst,

  input  [3:0]  io_be,
  input  [31:0] io_addr,
  input  [31:0] io_data_i,
  output [31:0] io_data_o,

  //RAM
  output [15:0]     RAM_logicRptNo,
  output [(8*3)-1:0]RAM_logicRptDelay,
  input   [31:0]    RAM_workfinish_cnt,
  output [0:0] RAM_trigDriver_DefLev,
  output [0:0] RAM_trigDriver_Trig,
  output [6:0] RAM_indTrig_Trig,
  output [0:0] RAM_syncTrig_workingMode,
  output [0:0] RAM_trigDriver_TrigMode,
  output [0:0] RAM_indTrig_TrigMode,

  output [7:0] RAM_syncTrig_Trig_First,
  output [7:0] RAM_syncTrig_Trig_DefLev,
  output [7:0] RAM_syncTrig_Fb_DefLev,
  output [6:0] RAM_indTrig_Trig_DefLev,

  output [(8*8) -1:0]  RAM_SwMtx_LayerEnd,
  output [(8*8) -1:0]  RAM_SwMtx_TriggerDelay,
  output [(8*8) -1:0]  RAM_SwMtx_FbDelay,
  output [(8*8) -1:0]  RAM_SwMtx_FbCatch,
  output [(8*8) -1:0]  RAM_SwMtx_LayerConf,
  output [(8*16) -1:0] RAM_SwMtc_LayerRepNo,
  output [(7*16) -1:0] RAM_SwMtc_IndRepNo,

  output [(8*3) -1:0] RAM_trigDirver_PulseWidth,

  output [(8*8*3) -1:0] RAM_syncTrig_Trig_PulseWidth,
  output [(8*8*3) -1:0] RAM_syncTrig_Trig_DelayCnt,
  output [(8*8*3) -1:0] RAM_syncTrig_Fb_DelayCnt,
  output [(8*8*3) -1:0] RAM_syncTrig_Fb_PulseWidth,

  output [(7*8*3) -1:0] RAM_indTrig_PulstWidth,
  output [(7*8*3) -1:0] RAM_indTrig_DelayCnt,
  //end RAM

  input [(8*8*4) - 1 : 0]  syncTrig_Timing1st,
  input [(8*8*4) - 1 : 0]  syncTrig_TimingMax,
  input [(8*8*4) - 1 : 0]  syncTrig_TimingMin,

  input [(8*8*2) - 1 :0]  syncTrig_PulseCounter,
  input [(8*8*2) - 1 :0]  syncTrig_FbCounter,

  input logicBusy,
  input [15:0] trigDriver_Counter
  ,input [16*7-1:0] indTrig_Counter
);
  wire C = io_clk;
  // wire R = io_rst;
  wire [3:0]BE = io_be;
  wire [31:0] A = io_addr;
  wire [31:0] D = io_data_i;

  //wire [31:0] testdata32 ;
  //assign testdata32 = 32'h04030201;
  reg [31:0] DATA_RD;
  assign io_data_o = DATA_RD;

  always @(*) begin
    case ({io_addr[31:2],2'd0})
      32'h0000 : DATA_RD = {RAM_logicRptNo,5'd0,RAM_trigDriver_DefLev,RAM_trigDriver_TrigMode,RAM_syncTrig_workingMode,7'd0,RAM_trigDriver_Trig };
      32'h0004 : DATA_RD = {RAM_logicRptDelay, 1'd0 ,RAM_indTrig_Trig};
      32'h0008 : DATA_RD = {RAM_indTrig_TrigMode,RAM_indTrig_Trig_DefLev,RAM_syncTrig_Fb_DefLev,RAM_syncTrig_Trig_DefLev,RAM_syncTrig_Trig_First};
      32'h000C : DATA_RD = {RAM_SwMtx_LayerEnd    [8*4*0 +: 8*4]};
      32'h0010 : DATA_RD = {RAM_SwMtx_LayerEnd    [8*4*1 +: 8*4]};
      32'h0014 : DATA_RD = {RAM_SwMtx_TriggerDelay[8*4*0 +: 8*4]};
      32'h0018 : DATA_RD = {RAM_SwMtx_TriggerDelay[8*4*1 +: 8*4]};
      32'h001C : DATA_RD = {RAM_SwMtx_FbCatch     [8*4*0 +: 8*4]};
      32'h0020 : DATA_RD = {RAM_SwMtx_FbCatch     [8*4*1 +: 8*4]};
      32'h0024 : DATA_RD = {RAM_SwMtx_LayerConf   [8*4*0 +: 8*4]};
      32'h0028 : DATA_RD = {RAM_SwMtx_LayerConf   [8*4*1 +: 8*4]};
      32'h002C : DATA_RD = {RAM_SwMtc_LayerRepNo  [8*4*0 +: 8*4]};
      32'h0030 : DATA_RD = {RAM_SwMtc_LayerRepNo  [8*4*1 +: 8*4]};
      32'h0034 : DATA_RD = {RAM_SwMtc_LayerRepNo  [8*4*2 +: 8*4]};
      32'h0038 : DATA_RD = {RAM_SwMtc_LayerRepNo  [8*4*3 +: 8*4]};
      32'h003C : DATA_RD = {RAM_SwMtc_IndRepNo    [8*4*0 +: 8*4]};
      32'h0040 : DATA_RD = {RAM_SwMtc_IndRepNo    [8*4*1 +: 8*4]};
      32'h0044 : DATA_RD = {RAM_SwMtc_IndRepNo    [8*4*2 +: 8*4]};
      32'h0048 : DATA_RD = {trigDriver_Counter ,RAM_SwMtc_IndRepNo[8*4*3 +: 8*2]};
      32'h004C : DATA_RD = {8'h0,RAM_trigDirver_PulseWidth};
      32'h0050 : DATA_RD = {8'h0,RAM_syncTrig_Trig_PulseWidth[8*3*0 +: 8*3]};
      32'h0054 : DATA_RD = {8'h0,RAM_syncTrig_Trig_PulseWidth[8*3*1 +: 8*3]};
      32'h0058 : DATA_RD = {8'h0,RAM_syncTrig_Trig_PulseWidth[8*3*2 +: 8*3]};
      32'h005C : DATA_RD = {8'h0,RAM_syncTrig_Trig_PulseWidth[8*3*3 +: 8*3]};
      32'h0060 : DATA_RD = {8'h0,RAM_syncTrig_Trig_PulseWidth[8*3*4 +: 8*3]};
      32'h0064 : DATA_RD = {8'h0,RAM_syncTrig_Trig_PulseWidth[8*3*5 +: 8*3]};
      32'h0068 : DATA_RD = {8'h0,RAM_syncTrig_Trig_PulseWidth[8*3*6 +: 8*3]};
      32'h006C : DATA_RD = {8'h0,RAM_syncTrig_Trig_PulseWidth[8*3*7 +: 8*3]};
      32'h0070 : DATA_RD = {8'h0,RAM_syncTrig_Trig_DelayCnt[8*3*0 +: 8*3]};
      32'h0074 : DATA_RD = {8'h0,RAM_syncTrig_Trig_DelayCnt[8*3*1 +: 8*3]};
      32'h0078 : DATA_RD = {8'h0,RAM_syncTrig_Trig_DelayCnt[8*3*2 +: 8*3]};
      32'h007C : DATA_RD = {8'h0,RAM_syncTrig_Trig_DelayCnt[8*3*3 +: 8*3]};
      32'h0080 : DATA_RD = {8'h0,RAM_syncTrig_Trig_DelayCnt[8*3*4 +: 8*3]};
      32'h0084 : DATA_RD = {8'h0,RAM_syncTrig_Trig_DelayCnt[8*3*5 +: 8*3]};
      32'h0088 : DATA_RD = {8'h0,RAM_syncTrig_Trig_DelayCnt[8*3*6 +: 8*3]};
      32'h008C : DATA_RD = {8'h0,RAM_syncTrig_Trig_DelayCnt[8*3*7 +: 8*3]};
      32'h0090 : DATA_RD = {8'h0,RAM_syncTrig_Fb_PulseWidth[8*3*0 +: 8*3]};
      32'h0094 : DATA_RD = {8'h0,RAM_syncTrig_Fb_PulseWidth[8*3*1 +: 8*3]};
      32'h0098 : DATA_RD = {8'h0,RAM_syncTrig_Fb_PulseWidth[8*3*2 +: 8*3]};
      32'h009C : DATA_RD = {8'h0,RAM_syncTrig_Fb_PulseWidth[8*3*3 +: 8*3]};
      32'h00A0 : DATA_RD = {8'h0,RAM_syncTrig_Fb_PulseWidth[8*3*4 +: 8*3]};
      32'h00A4 : DATA_RD = {8'h0,RAM_syncTrig_Fb_PulseWidth[8*3*5 +: 8*3]};
      32'h00A8 : DATA_RD = {8'h0,RAM_syncTrig_Fb_PulseWidth[8*3*6 +: 8*3]};
      32'h00AC : DATA_RD = {8'h0,RAM_syncTrig_Fb_PulseWidth[8*3*7 +: 8*3]};
      32'h00B0 : DATA_RD = {8'h0,RAM_indTrig_PulstWidth[8*3*0 +: 8*3]};
      32'h00B4 : DATA_RD = {8'h0,RAM_indTrig_PulstWidth[8*3*1 +: 8*3]};
      32'h00B8 : DATA_RD = {8'h0,RAM_indTrig_PulstWidth[8*3*2 +: 8*3]};
      32'h00BC : DATA_RD = {8'h0,RAM_indTrig_PulstWidth[8*3*3 +: 8*3]};
      32'h00C0 : DATA_RD = {8'h0,RAM_indTrig_PulstWidth[8*3*4 +: 8*3]};
      32'h00C4 : DATA_RD = {8'h0,RAM_indTrig_PulstWidth[8*3*5 +: 8*3]};
      32'h00C8 : DATA_RD = {8'h0,RAM_indTrig_PulstWidth[8*3*6 +: 8*3]};
      32'h00CC : DATA_RD = {8'h0,RAM_indTrig_DelayCnt[8*3*0 +: 8*3]};
      32'h00D0 : DATA_RD = {8'h0,RAM_indTrig_DelayCnt[8*3*1 +: 8*3]};
      32'h00D4 : DATA_RD = {8'h0,RAM_indTrig_DelayCnt[8*3*2 +: 8*3]};
      32'h00D8 : DATA_RD = {8'h0,RAM_indTrig_DelayCnt[8*3*3 +: 8*3]};
      32'h00DC : DATA_RD = {8'h0,RAM_indTrig_DelayCnt[8*3*4 +: 8*3]};
      32'h00E0 : DATA_RD = {8'h0,RAM_indTrig_DelayCnt[8*3*5 +: 8*3]};
      32'h00E4 : DATA_RD = {8'h0,RAM_indTrig_DelayCnt[8*3*6 +: 8*3]};

      32'h00E8 : DATA_RD = {syncTrig_Timing1st[8*4*0 +: 8*4]};
      32'h00EC : DATA_RD = {syncTrig_Timing1st[8*4*1 +: 8*4]};
      32'h00F0 : DATA_RD = {syncTrig_Timing1st[8*4*2 +: 8*4]};
      32'h00F4 : DATA_RD = {syncTrig_Timing1st[8*4*3 +: 8*4]};
      32'h00F8 : DATA_RD = {syncTrig_Timing1st[8*4*4 +: 8*4]};
      32'h00FC : DATA_RD = {syncTrig_Timing1st[8*4*5 +: 8*4]};
      32'h0100 : DATA_RD = {syncTrig_Timing1st[8*4*6 +: 8*4]};
      32'h0104 : DATA_RD = {syncTrig_Timing1st[8*4*7 +: 8*4]};
      32'h0108 : DATA_RD = {syncTrig_TimingMax[8*4*0 +: 8*4]};
      32'h010C : DATA_RD = {syncTrig_TimingMax[8*4*1 +: 8*4]};
      32'h0110 : DATA_RD = {syncTrig_TimingMax[8*4*2 +: 8*4]};
      32'h0114 : DATA_RD = {syncTrig_TimingMax[8*4*3 +: 8*4]};
      32'h0118 : DATA_RD = {syncTrig_TimingMax[8*4*4 +: 8*4]};
      32'h011C : DATA_RD = {syncTrig_TimingMax[8*4*5 +: 8*4]};
      32'h0120 : DATA_RD = {syncTrig_TimingMax[8*4*6 +: 8*4]};
      32'h0124 : DATA_RD = {syncTrig_TimingMax[8*4*7 +: 8*4]};
      32'h0128 : DATA_RD = {syncTrig_TimingMin[8*4*0 +: 8*4]};
      32'h012C : DATA_RD = {syncTrig_TimingMin[8*4*1 +: 8*4]};
      32'h0130 : DATA_RD = {syncTrig_TimingMin[8*4*2 +: 8*4]};
      32'h0134 : DATA_RD = {syncTrig_TimingMin[8*4*3 +: 8*4]};
      32'h0138 : DATA_RD = {syncTrig_TimingMin[8*4*4 +: 8*4]};
      32'h013C : DATA_RD = {syncTrig_TimingMin[8*4*5 +: 8*4]};
      32'h0140 : DATA_RD = {syncTrig_TimingMin[8*4*6 +: 8*4]};
      32'h0144 : DATA_RD = {syncTrig_TimingMin[8*4*7 +: 8*4]};

      32'h0148 : DATA_RD = {syncTrig_PulseCounter[8*4*0 +: 8*4]};
      32'h014C : DATA_RD = {syncTrig_PulseCounter[8*4*1 +: 8*4]};
      32'h0150 : DATA_RD = {syncTrig_PulseCounter[8*4*2 +: 8*4]};
      32'h0154 : DATA_RD = {syncTrig_PulseCounter[8*4*3 +: 8*4]};
      32'h0158 : DATA_RD = {syncTrig_FbCounter[8*4*0 +: 8*4]};
      32'h015C : DATA_RD = {syncTrig_FbCounter[8*4*1 +: 8*4]};
      32'h0160 : DATA_RD = {syncTrig_FbCounter[8*4*2 +: 8*4]};
      32'h0164 : DATA_RD = {syncTrig_FbCounter[8*4*3 +: 8*4]};
      32'h0168 : DATA_RD = {indTrig_Counter[8*2*6 +:8*2],15'b0,logicBusy};

      32'h016C : DATA_RD = {RAM_SwMtx_FbDelay[8*4*0 +: 8*4]};
      32'h0170 : DATA_RD = {RAM_SwMtx_FbDelay[8*4*1 +: 8*4]};
      32'h0174 : DATA_RD = {8'h0,RAM_syncTrig_Fb_DelayCnt[8*3*0 +: 8*3]};
      32'h0178 : DATA_RD = {8'h0,RAM_syncTrig_Fb_DelayCnt[8*3*1 +: 8*3]};
      32'h017C : DATA_RD = {8'h0,RAM_syncTrig_Fb_DelayCnt[8*3*2 +: 8*3]};
      32'h0180 : DATA_RD = {8'h0,RAM_syncTrig_Fb_DelayCnt[8*3*3 +: 8*3]};
      32'h0184 : DATA_RD = {8'h0,RAM_syncTrig_Fb_DelayCnt[8*3*4 +: 8*3]};
      32'h0188 : DATA_RD = {8'h0,RAM_syncTrig_Fb_DelayCnt[8*3*5 +: 8*3]};
      32'h018C : DATA_RD = {8'h0,RAM_syncTrig_Fb_DelayCnt[8*3*6 +: 8*3]};
      32'h0190 : DATA_RD = {8'h0,RAM_syncTrig_Fb_DelayCnt[8*3*7 +: 8*3]};
      32'h0194 : DATA_RD = {indTrig_Counter[8*2*1 +:8*2],indTrig_Counter[8*2*0 +:8*2]};
      32'h0198 : DATA_RD = {indTrig_Counter[8*2*3 +:8*2],indTrig_Counter[8*2*2 +:8*2]};
      32'h019C : DATA_RD = {indTrig_Counter[8*2*5 +:8*2],indTrig_Counter[8*2*4 +:8*2]};
      32'h0200 : DATA_RD = RAM_workfinish_cnt;

      default : DATA_RD = 32'h0;
    endcase
  end
  
  wire [15:0] DATA_X0000;
  wire  [7:0] DATA_X0004;
  reg busTrig = 0;
  reg [8:0] busTrig_r = 0;
  reg indBusTrig0 = 0;
  reg indBusTrig1 = 0;
  reg indBusTrig2 = 0;
  reg indBusTrig3 = 0;
  reg indBusTrig4 = 0;
  reg indBusTrig5 = 0;
  reg indBusTrig6 = 0;
  reg [8:0] indBusTrig0_r = 0;
  reg [8:0] indBusTrig1_r = 0;
  reg [8:0] indBusTrig2_r = 0;
  reg [8:0] indBusTrig3_r = 0;
  reg [8:0] indBusTrig4_r = 0;
  reg [8:0] indBusTrig5_r = 0;
  reg [8:0] indBusTrig6_r = 0;
  always @ (posedge io_clk) begin
    busTrig <= (A[31:2] == 'd0) & BE[0] & D[0];
    busTrig_r <= {busTrig_r[7:0],busTrig};

    indBusTrig0 <= ({A[31:2],2'd0} == 'h4) & BE[0] & D[0];
    indBusTrig1 <= ({A[31:2],2'd0} == 'h4) & BE[0] & D[1];
    indBusTrig2 <= ({A[31:2],2'd0} == 'h4) & BE[0] & D[2];
    indBusTrig3 <= ({A[31:2],2'd0} == 'h4) & BE[0] & D[3];
    indBusTrig4 <= ({A[31:2],2'd0} == 'h4) & BE[0] & D[4];
    indBusTrig5 <= ({A[31:2],2'd0} == 'h4) & BE[0] & D[5];
    indBusTrig6 <= ({A[31:2],2'd0} == 'h4) & BE[0] & D[6];

    indBusTrig0_r <= {indBusTrig0_r[7:0],indBusTrig0};
    indBusTrig1_r <= {indBusTrig1_r[7:0],indBusTrig1};
    indBusTrig2_r <= {indBusTrig2_r[7:0],indBusTrig2};
    indBusTrig3_r <= {indBusTrig3_r[7:0],indBusTrig3};
    indBusTrig4_r <= {indBusTrig4_r[7:0],indBusTrig4};
    indBusTrig5_r <= {indBusTrig5_r[7:0],indBusTrig5};
    indBusTrig6_r <= {indBusTrig6_r[7:0],indBusTrig6};
  end
  assign RAM_trigDriver_Trig      = |busTrig_r;
  //assign RAM_indTrig_TrigMode     = DATA_X0000[11];
  assign RAM_trigDriver_DefLev    = DATA_X0000[10];
  assign RAM_syncTrig_workingMode = DATA_X0000[8];
  assign RAM_trigDriver_TrigMode  = DATA_X0000[9];

  assign RAM_indTrig_Trig[0] = |indBusTrig0_r;
  assign RAM_indTrig_Trig[1] = |indBusTrig1_r;
  assign RAM_indTrig_Trig[2] = |indBusTrig2_r;
  assign RAM_indTrig_Trig[3] = |indBusTrig3_r;
  assign RAM_indTrig_Trig[4] = |indBusTrig4_r;
  assign RAM_indTrig_Trig[5] = |indBusTrig5_r;
  assign RAM_indTrig_Trig[6] = |indBusTrig6_r;

  BUS_CATCH #('h0000,'d4) X0000 (C,BE,A,D, {RAM_logicRptNo,DATA_X0000});
  BUS_CATCH #('h0004,'d4) X0004 (C,BE,A,D, {RAM_logicRptDelay,DATA_X0004});
  BUS_CATCH #('h0008,'d4) X0008 (C,BE,A,D, {RAM_indTrig_TrigMode,RAM_indTrig_Trig_DefLev,RAM_syncTrig_Fb_DefLev,RAM_syncTrig_Trig_DefLev,RAM_syncTrig_Trig_First});
  BUS_CATCH #('h000C,'d4) X000C (C,BE,A,D, {RAM_SwMtx_LayerEnd    [8*4*0 +: 8*4]});
  BUS_CATCH #('h0010,'d4) X0010 (C,BE,A,D, {RAM_SwMtx_LayerEnd    [8*4*1 +: 8*4]});
  BUS_CATCH #('h0014,'d4) X0014 (C,BE,A,D, {RAM_SwMtx_TriggerDelay[8*4*0 +: 8*4]});
  BUS_CATCH #('h0018,'d4) X0018 (C,BE,A,D, {RAM_SwMtx_TriggerDelay[8*4*1 +: 8*4]});
  BUS_CATCH #('h001C,'d4) X001C (C,BE,A,D, {RAM_SwMtx_FbCatch     [8*4*0 +: 8*4]});
  BUS_CATCH #('h0020,'d4) X0020 (C,BE,A,D, {RAM_SwMtx_FbCatch     [8*4*1 +: 8*4]});
  BUS_CATCH #('h0024,'d4) X0024 (C,BE,A,D, {RAM_SwMtx_LayerConf   [8*4*0 +: 8*4]});
  BUS_CATCH #('h0028,'d4) X0028 (C,BE,A,D, {RAM_SwMtx_LayerConf   [8*4*1 +: 8*4]});
  BUS_CATCH #('h002C,'d4) X002C (C,BE,A,D, {RAM_SwMtc_LayerRepNo  [8*4*0 +: 8*4]});
  BUS_CATCH #('h0030,'d4) X0030 (C,BE,A,D, {RAM_SwMtc_LayerRepNo  [8*4*1 +: 8*4]});
  BUS_CATCH #('h0034,'d4) X0034 (C,BE,A,D, {RAM_SwMtc_LayerRepNo  [8*4*2 +: 8*4]});
  BUS_CATCH #('h0038,'d4) X0038 (C,BE,A,D, {RAM_SwMtc_LayerRepNo  [8*4*3 +: 8*4]});
  BUS_CATCH #('h003C,'d4) X003C (C,BE,A,D, {RAM_SwMtc_IndRepNo    [8*4*0 +: 8*4]});
  BUS_CATCH #('h0040,'d4) X0040 (C,BE,A,D, {RAM_SwMtc_IndRepNo    [8*4*1 +: 8*4]});
  BUS_CATCH #('h0044,'d4) X0044 (C,BE,A,D, {RAM_SwMtc_IndRepNo    [8*4*2 +: 8*4]});
  BUS_CATCH #('h0048,'d2) X0048 (C,BE,A,D, {RAM_SwMtc_IndRepNo    [8*4*3 +: 8*2]});
  BUS_CATCH #('h004C,'d3) X004C (C,BE,A,D, RAM_trigDirver_PulseWidth);
  BUS_CATCH #('h0050,'d3) X0050 (C,BE,A,D, RAM_syncTrig_Trig_PulseWidth[8*3*0 +: 8*3]);
  BUS_CATCH #('h0054,'d3) X0054 (C,BE,A,D, RAM_syncTrig_Trig_PulseWidth[8*3*1 +: 8*3]);
  BUS_CATCH #('h0058,'d3) X0058 (C,BE,A,D, RAM_syncTrig_Trig_PulseWidth[8*3*2 +: 8*3]);
  BUS_CATCH #('h005C,'d3) X005C (C,BE,A,D, RAM_syncTrig_Trig_PulseWidth[8*3*3 +: 8*3]);
  BUS_CATCH #('h0060,'d3) X0060 (C,BE,A,D, RAM_syncTrig_Trig_PulseWidth[8*3*4 +: 8*3]);
  BUS_CATCH #('h0064,'d3) X0064 (C,BE,A,D, RAM_syncTrig_Trig_PulseWidth[8*3*5 +: 8*3]);
  BUS_CATCH #('h0068,'d3) X0068 (C,BE,A,D, RAM_syncTrig_Trig_PulseWidth[8*3*6 +: 8*3]);
  BUS_CATCH #('h006C,'d3) X006C (C,BE,A,D, RAM_syncTrig_Trig_PulseWidth[8*3*7 +: 8*3]);
  BUS_CATCH #('h0070,'d3) X0070 (C,BE,A,D, RAM_syncTrig_Trig_DelayCnt[8*3*0 +: 8*3]);
  BUS_CATCH #('h0074,'d3) X0074 (C,BE,A,D, RAM_syncTrig_Trig_DelayCnt[8*3*1 +: 8*3]);
  BUS_CATCH #('h0078,'d3) X0078 (C,BE,A,D, RAM_syncTrig_Trig_DelayCnt[8*3*2 +: 8*3]);
  BUS_CATCH #('h007C,'d3) X007C (C,BE,A,D, RAM_syncTrig_Trig_DelayCnt[8*3*3 +: 8*3]);
  BUS_CATCH #('h0080,'d3) X0080 (C,BE,A,D, RAM_syncTrig_Trig_DelayCnt[8*3*4 +: 8*3]);
  BUS_CATCH #('h0084,'d3) X0084 (C,BE,A,D, RAM_syncTrig_Trig_DelayCnt[8*3*5 +: 8*3]);
  BUS_CATCH #('h0088,'d3) X0088 (C,BE,A,D, RAM_syncTrig_Trig_DelayCnt[8*3*6 +: 8*3]);
  BUS_CATCH #('h008C,'d3) X008C (C,BE,A,D, RAM_syncTrig_Trig_DelayCnt[8*3*7 +: 8*3]);
  BUS_CATCH #('h0090,'d3) X0090 (C,BE,A,D, RAM_syncTrig_Fb_PulseWidth[8*3*0 +: 8*3]);
  BUS_CATCH #('h0094,'d3) X0094 (C,BE,A,D, RAM_syncTrig_Fb_PulseWidth[8*3*1 +: 8*3]);
  BUS_CATCH #('h0098,'d3) X0098 (C,BE,A,D, RAM_syncTrig_Fb_PulseWidth[8*3*2 +: 8*3]);
  BUS_CATCH #('h009C,'d3) X009C (C,BE,A,D, RAM_syncTrig_Fb_PulseWidth[8*3*3 +: 8*3]);
  BUS_CATCH #('h00A0,'d3) X00A0 (C,BE,A,D, RAM_syncTrig_Fb_PulseWidth[8*3*4 +: 8*3]);
  BUS_CATCH #('h00A4,'d3) X00A4 (C,BE,A,D, RAM_syncTrig_Fb_PulseWidth[8*3*5 +: 8*3]);
  BUS_CATCH #('h00A8,'d3) X00A8 (C,BE,A,D, RAM_syncTrig_Fb_PulseWidth[8*3*6 +: 8*3]);
  BUS_CATCH #('h00AC,'d3) X00AC (C,BE,A,D, RAM_syncTrig_Fb_PulseWidth[8*3*7 +: 8*3]);
  BUS_CATCH #('h00B0,'d3) X00B0 (C,BE,A,D, RAM_indTrig_PulstWidth[8*3*0 +: 8*3]);
  BUS_CATCH #('h00B4,'d3) X00B4 (C,BE,A,D, RAM_indTrig_PulstWidth[8*3*1 +: 8*3]);
  BUS_CATCH #('h00B8,'d3) X00B8 (C,BE,A,D, RAM_indTrig_PulstWidth[8*3*2 +: 8*3]);
  BUS_CATCH #('h00BC,'d3) X00BC (C,BE,A,D, RAM_indTrig_PulstWidth[8*3*3 +: 8*3]);
  BUS_CATCH #('h00C0,'d3) X00C0 (C,BE,A,D, RAM_indTrig_PulstWidth[8*3*4 +: 8*3]);
  BUS_CATCH #('h00C4,'d3) X00C4 (C,BE,A,D, RAM_indTrig_PulstWidth[8*3*5 +: 8*3]);
  BUS_CATCH #('h00C8,'d3) X00C8 (C,BE,A,D, RAM_indTrig_PulstWidth[8*3*6 +: 8*3]);
  BUS_CATCH #('h00CC,'d3) X00CC (C,BE,A,D, RAM_indTrig_DelayCnt[8*3*0 +: 8*3]);
  BUS_CATCH #('h00D0,'d3) X00D0 (C,BE,A,D, RAM_indTrig_DelayCnt[8*3*1 +: 8*3]);
  BUS_CATCH #('h00D4,'d3) X00D4 (C,BE,A,D, RAM_indTrig_DelayCnt[8*3*2 +: 8*3]);
  BUS_CATCH #('h00D8,'d3) X00D8 (C,BE,A,D, RAM_indTrig_DelayCnt[8*3*3 +: 8*3]);
  BUS_CATCH #('h00DC,'d3) X00DC (C,BE,A,D, RAM_indTrig_DelayCnt[8*3*4 +: 8*3]);
  BUS_CATCH #('h00E0,'d3) X00E0 (C,BE,A,D, RAM_indTrig_DelayCnt[8*3*5 +: 8*3]);
  BUS_CATCH #('h00E4,'d3) X00E4 (C,BE,A,D, RAM_indTrig_DelayCnt[8*3*6 +: 8*3]);

  BUS_CATCH #('h016C,'d4) X016C (C,BE,A,D, RAM_SwMtx_FbDelay[8*4*0 +: 8*4]);
  BUS_CATCH #('h0170,'d4) X0170 (C,BE,A,D, RAM_SwMtx_FbDelay[8*4*1 +: 8*4]);
  BUS_CATCH #('h0174,'d3) X0174 (C,BE,A,D, RAM_syncTrig_Fb_DelayCnt[8*3*0 +: 8*3]);
  BUS_CATCH #('h0178,'d3) X0178 (C,BE,A,D, RAM_syncTrig_Fb_DelayCnt[8*3*1 +: 8*3]);
  BUS_CATCH #('h017C,'d3) X017C (C,BE,A,D, RAM_syncTrig_Fb_DelayCnt[8*3*2 +: 8*3]);
  BUS_CATCH #('h0180,'d3) X0180 (C,BE,A,D, RAM_syncTrig_Fb_DelayCnt[8*3*3 +: 8*3]);
  BUS_CATCH #('h0184,'d3) X0184 (C,BE,A,D, RAM_syncTrig_Fb_DelayCnt[8*3*4 +: 8*3]);
  BUS_CATCH #('h0188,'d3) X0188 (C,BE,A,D, RAM_syncTrig_Fb_DelayCnt[8*3*5 +: 8*3]);
  BUS_CATCH #('h018C,'d3) X018C (C,BE,A,D, RAM_syncTrig_Fb_DelayCnt[8*3*6 +: 8*3]);
  BUS_CATCH #('h0190,'d3) X0190 (C,BE,A,D, RAM_syncTrig_Fb_DelayCnt[8*3*7 +: 8*3]);

endmodule
