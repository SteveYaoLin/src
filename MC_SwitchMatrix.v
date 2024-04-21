module MC_SwitchMatrix (
  input [31:0] io_portSig,
  input [31:0] io_defLev,
  input [(32*32)-1:0] io_Switch,
  input io_bcd,
  output [31:0] io_portOut
);

  wire [31:0] swOut;
  reg [(32*32-1):0] Switch_bcd;
  wire [(32*32-1):0] digi_switch;
  wire  delflev;
  assign delflev = |io_defLev;//(io_bcd)? 32'h0 : io_defLev;
  genvar j ;
  generate
    for (j=0;j<32;j=j+1) begin : BCD_gen
      //assign  Switch_bcd[(j+1)*32 : 0] =  
    always @(*) begin
      case (io_Switch[(j+1)*32 -1: (32*j)])
        32'h0000_0001 : Switch_bcd[(j+1)*32 -1: (32*j)] = 32'h0000_0001 ;
        32'h0000_0002 : Switch_bcd[(j+1)*32 -1: (32*j)] = 32'h0000_0002 ;
        32'h0000_0004 : Switch_bcd[(j+1)*32 -1: (32*j)] = 32'h0000_0003 ;
        32'h0000_0008 : Switch_bcd[(j+1)*32 -1: (32*j)] = 32'h0000_0004 ;
        32'h0000_0010 : Switch_bcd[(j+1)*32 -1: (32*j)] = 32'h0000_0005 ;
        32'h0000_0020 : Switch_bcd[(j+1)*32 -1: (32*j)] = 32'h0000_0006 ;
        32'h0000_0040 : Switch_bcd[(j+1)*32 -1: (32*j)] = 32'h0000_0007 ;
        32'h0000_0080 : Switch_bcd[(j+1)*32 -1: (32*j)] = 32'h0000_0008 ;
        32'h0000_0100 : Switch_bcd[(j+1)*32 -1: (32*j)] = 32'h0000_0009 ;
        32'h0000_0200 : Switch_bcd[(j+1)*32 -1: (32*j)] = 32'h0000_000a ;
        32'h0000_0400 : Switch_bcd[(j+1)*32 -1: (32*j)] = 32'h0000_000b ;
        32'h0000_0800 : Switch_bcd[(j+1)*32 -1: (32*j)] = 32'h0000_000c ;
        32'h0000_1000 : Switch_bcd[(j+1)*32 -1: (32*j)] = 32'h0000_000d ;
        32'h0000_2000 : Switch_bcd[(j+1)*32 -1: (32*j)] = 32'h0000_000e ;
        32'h0000_4000 : Switch_bcd[(j+1)*32 -1: (32*j)] = 32'h0000_000f ;
        32'h0000_8000 : Switch_bcd[(j+1)*32 -1: (32*j)] = 32'h0000_0010 ;
        32'h0001_0000 : Switch_bcd[(j+1)*32 -1: (32*j)] = 32'h0000_0011 ;
        32'h0002_0000 : Switch_bcd[(j+1)*32 -1: (32*j)] = 32'h0000_0012 ;
        32'h0004_0000 : Switch_bcd[(j+1)*32 -1: (32*j)] = 32'h0000_0013 ;
        32'h0008_0000 : Switch_bcd[(j+1)*32 -1: (32*j)] = 32'h0000_0014 ;
        32'h0010_0000 : Switch_bcd[(j+1)*32 -1: (32*j)] = 32'h0000_0015 ;
        32'h0020_0000 : Switch_bcd[(j+1)*32 -1: (32*j)] = 32'h0000_0016 ;
        32'h0040_0000 : Switch_bcd[(j+1)*32 -1: (32*j)] = 32'h0000_0017 ;
        32'h0080_0000 : Switch_bcd[(j+1)*32 -1: (32*j)] = 32'h0000_0018 ;
        32'h0100_0000 : Switch_bcd[(j+1)*32 -1: (32*j)] = 32'h0000_0019 ;
        32'h0200_0000 : Switch_bcd[(j+1)*32 -1: (32*j)] = 32'h0000_001a ;
        32'h0400_0000 : Switch_bcd[(j+1)*32 -1: (32*j)] = 32'h0000_001b ;
        32'h0800_0000 : Switch_bcd[(j+1)*32 -1: (32*j)] = 32'h0000_001c ;
        32'h1000_0000 : Switch_bcd[(j+1)*32 -1: (32*j)] = 32'h0000_001d ;
        32'h2000_0000 : Switch_bcd[(j+1)*32 -1: (32*j)] = 32'h0000_001e ;
        32'h4000_0000 : Switch_bcd[(j+1)*32 -1: (32*j)] = 32'h0000_001f ;
        32'h8000_0000 : Switch_bcd[(j+1)*32 -1: (32*j)] = 32'h0000_0020 ;
    
        default: begin
          Switch_bcd[(j+1)*32 -1: (32*j)] = 32'h0;
        end
      endcase
    end
    end
  endgenerate
  assign digi_switch = io_bcd ? Switch_bcd : io_Switch ;
  genvar i;
  generate
    for(i=0; i<32; i=i+1) begin:switchMatrix

      assign io_portOut[i] = swOut[i] ^ delflev;//io_defLev[i];

      assign swOut[i] =(
                        io_portSig [0] & digi_switch[ 0*32 + i] |
                        io_portSig [1] & digi_switch[ 1*32 + i] |
                        io_portSig [2] & digi_switch[ 2*32 + i] |
                        io_portSig [3] & digi_switch[ 3*32 + i] |
                        io_portSig [4] & digi_switch[ 4*32 + i] |
                        io_portSig [5] & digi_switch[ 5*32 + i] |
                        io_portSig [6] & digi_switch[ 6*32 + i] |
                        io_portSig [7] & digi_switch[ 7*32 + i] |
                        io_portSig [8] & digi_switch[ 8*32 + i] |
                        io_portSig [9] & digi_switch[ 9*32 + i] |
                        io_portSig[10] & digi_switch[10*32 + i] |
                        io_portSig[11] & digi_switch[11*32 + i] |
                        io_portSig[12] & digi_switch[12*32 + i] |
                        io_portSig[13] & digi_switch[13*32 + i] |
                        io_portSig[14] & digi_switch[14*32 + i] |
                        io_portSig[15] & digi_switch[15*32 + i] |
                        io_portSig[16] & digi_switch[16*32 + i] |
                        io_portSig[17] & digi_switch[17*32 + i] |
                        io_portSig[18] & digi_switch[18*32 + i] |
                        io_portSig[19] & digi_switch[19*32 + i] |
                        io_portSig[20] & digi_switch[20*32 + i] |
                        io_portSig[21] & digi_switch[21*32 + i] |
                        io_portSig[22] & digi_switch[22*32 + i] |
                        io_portSig[23] & digi_switch[23*32 + i] |
                        io_portSig[24] & digi_switch[24*32 + i] |
                        io_portSig[25] & digi_switch[25*32 + i] |
                        io_portSig[26] & digi_switch[26*32 + i] |
                        io_portSig[27] & digi_switch[27*32 + i] |
                        io_portSig[28] & digi_switch[28*32 + i] |
                        io_portSig[29] & digi_switch[29*32 + i] |
                        io_portSig[30] & digi_switch[30*32 + i] |
                        io_portSig[31] & digi_switch[31*32 + i] );
    end
  endgenerate  /*switchMatrix*/

endmodule
