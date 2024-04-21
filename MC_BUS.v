module MC_BUS(
  input io_clk,


  input  [3:0]  io_be,
  input  [31:0] io_addr,
  input  [31:0] io_data_i,
  output [31:0] io_data_o,

  output RAM_mode,
  output RAM_bcd,
  output RAM_TrigMod,
  output RAM_TrigDeflev,
  output RAM_FbDeflev,

  output [(8*3)-1:0] RAM_TrigPulseWidth,
  output [(8*3)-1:0] RAM_pulseWidth,
  output [(8*2)-1:0] RAM_fbWidth,
  output [5:0] RAM_portNo,
  output [(8*3)-1:0] RAM_fbDelay,
  output RAM_busTrig,
  output RAM_busfinish,
  output [15:0] RAM_rptNo,
  output [31:0] RAM_defLev,

  output [(32*32)-1 :0 ] RAM_SW,
  //end RAM

  input [15:0] catchCounter,
  input [15:0] fbCounter,
  input [(16*32) -1:0] outCounter
);
  wire C = io_clk;
  // wire R = io_rst;
  wire [3:0]BE = io_be;
  wire [31:0] A = io_addr;
  wire [31:0] D = io_data_i;

  reg [31:0] DATA_RD;
  assign io_data_o = DATA_RD;


  always @(*) begin
    case ({io_addr[31:2],2'd0})
      'h200:DATA_RD = {RAM_TrigPulseWidth,5'd0,RAM_TrigMod,RAM_bcd,RAM_mode};//减少默认电平
      'h204:DATA_RD = {RAM_pulseWidth,2'd0,RAM_portNo};
      'h208:DATA_RD = {8'd0,RAM_fbDelay};
      'h20c:DATA_RD = {RAM_fbWidth,RAM_rptNo};//在20d增加默认电平，重复次数改为8bit
      'h210:DATA_RD = {24'h0,6'b000000,RAM_FbDeflev,RAM_TrigDeflev};
      'h214:DATA_RD = {RAM_defLev};
                    
      'h218:DATA_RD = RAM_SW[  0 * 32 +: 32];
      'h21c:DATA_RD = RAM_SW[  1 * 32 +: 32];
      'h220:DATA_RD = RAM_SW[  2 * 32 +: 32];
      'h224:DATA_RD = RAM_SW[  3 * 32 +: 32];
      'h228:DATA_RD = RAM_SW[  4 * 32 +: 32];
      'h22c:DATA_RD = RAM_SW[  5 * 32 +: 32];
      'h230:DATA_RD = RAM_SW[  6 * 32 +: 32];
      'h234:DATA_RD = RAM_SW[  7 * 32 +: 32];
      'h238:DATA_RD = RAM_SW[  8 * 32 +: 32];
      'h23c:DATA_RD = RAM_SW[  9 * 32 +: 32];
      'h240:DATA_RD = RAM_SW[ 10 * 32 +: 32];
      'h244:DATA_RD = RAM_SW[ 11 * 32 +: 32];
      'h248:DATA_RD = RAM_SW[ 12 * 32 +: 32];
      'h24c:DATA_RD = RAM_SW[ 13 * 32 +: 32];
      'h250:DATA_RD = RAM_SW[ 14 * 32 +: 32];
      'h254:DATA_RD = RAM_SW[ 15 * 32 +: 32];
      'h258:DATA_RD = RAM_SW[ 16 * 32 +: 32];
      'h25c:DATA_RD = RAM_SW[ 17 * 32 +: 32];
      'h260:DATA_RD = RAM_SW[ 18 * 32 +: 32];
      'h264:DATA_RD = RAM_SW[ 19 * 32 +: 32];
      'h268:DATA_RD = RAM_SW[ 20 * 32 +: 32];
      'h26c:DATA_RD = RAM_SW[ 21 * 32 +: 32];
      'h270:DATA_RD = RAM_SW[ 22 * 32 +: 32];
      'h274:DATA_RD = RAM_SW[ 23 * 32 +: 32];
      'h278:DATA_RD = RAM_SW[ 24 * 32 +: 32];
      'h27c:DATA_RD = RAM_SW[ 25 * 32 +: 32];
      'h280:DATA_RD = RAM_SW[ 26 * 32 +: 32];
      'h284:DATA_RD = RAM_SW[ 27 * 32 +: 32];
      'h288:DATA_RD = RAM_SW[ 28 * 32 +: 32];
      'h28c:DATA_RD = RAM_SW[ 29 * 32 +: 32];
      'h290:DATA_RD = RAM_SW[ 30 * 32 +: 32];
      'h294:DATA_RD = RAM_SW[ 31 * 32 +: 32];

      'h298 : DATA_RD = {fbCounter,catchCounter};
      'h29c : DATA_RD = {outCounter[  0 * 32 +:32]};
      'h2a0 : DATA_RD = {outCounter[  1 * 32 +:32]};
      'h2a4 : DATA_RD = {outCounter[  2 * 32 +:32]};
      'h2a8 : DATA_RD = {outCounter[  3 * 32 +:32]};
      'h2ac : DATA_RD = {outCounter[  4 * 32 +:32]};
      'h2b0 : DATA_RD = {outCounter[  5 * 32 +:32]};
      'h2b4 : DATA_RD = {outCounter[  6 * 32 +:32]};
      'h2b8 : DATA_RD = {outCounter[  7 * 32 +:32]};
      'h2bc : DATA_RD = {outCounter[  8 * 32 +:32]};
      'h2c0 : DATA_RD = {outCounter[  9 * 32 +:32]};
      'h2c4 : DATA_RD = {outCounter[ 10 * 32 +:32]};
      'h2c8 : DATA_RD = {outCounter[ 11 * 32 +:32]};
      'h2cc : DATA_RD = {outCounter[ 12 * 32 +:32]};
      'h2d0 : DATA_RD = {outCounter[ 13 * 32 +:32]};
      'h2d4 : DATA_RD = {outCounter[ 14 * 32 +:32]};
      'h2d8 : DATA_RD = {outCounter[ 15 * 32 +:32]};

      default : DATA_RD = 32'h0;
    endcase
  end


  wire [7:0] DATA_X0200;
  wire [7:0] DATA_X0204;
  wire [31:0] DATA_X0210;
  reg busTrig = 0;
  reg [8:0] busTrig_r = 0;

  reg busfinish = 0;
  reg [8:0] busfinish_r = 0;
  always @ (posedge io_clk) begin
    busTrig <= ({A[31:2],2'd0} == 'h0208) & BE == 4'b1000 & D[24];
    busTrig_r <= {busTrig_r[7:0],busTrig};
  end
  assign RAM_busTrig      = |busTrig_r;
  always @ (posedge io_clk) begin
    busfinish <= ({A[31:2],2'd0} == 'h0208) & BE == 4'b1000 & D[25];
    busfinish_r <= {busfinish_r[7:0],busfinish};
  end
  assign RAM_busfinish      = |busfinish_r;


  assign RAM_mode        = DATA_X0200[0];
  assign RAM_bcd         = DATA_X0200[1];
  assign RAM_TrigMod     = DATA_X0200[2];
  assign RAM_TrigDeflev  = DATA_X0210[0];
  assign RAM_FbDeflev    = DATA_X0210[1];
  assign RAM_portNo      = DATA_X0204[5:0];

  BUS_CATCH #('h0200,'d4) X0200 (C,BE,A,D, {RAM_TrigPulseWidth,DATA_X0200});
  BUS_CATCH #('h0204,'d4) X0204 (C,BE,A,D, {RAM_pulseWidth,DATA_X0204});
  BUS_CATCH #('h0208,'d3) X0208 (C,BE,A,D, {RAM_fbDelay});
  BUS_CATCH #('h020c,'d4) X020c (C,BE,A,D, {RAM_fbWidth,RAM_rptNo});
  BUS_CATCH #('h0210,'d1) X0210 (C,BE,A,D, {DATA_X0210});
  BUS_CATCH #('h0214,'d4) X0214 (C,BE,A,D, {RAM_defLev});

  genvar i;
  generate
    for(i=0; i<32; i=i+1) begin:SWBus
      BUS_CATCH #(('h218+(i*4)),'d4) SW (C,BE,A,D,{RAM_SW[i*32 +:32]});
    end
  endgenerate  /*SWBus*/


endmodule
