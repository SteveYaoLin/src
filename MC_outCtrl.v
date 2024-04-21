module MC_outCtrl (
  input io_clk,
  input io_rst,

  input io_catch,
  input finish,
  input io_mode,  //模式  0: 脉冲 1:电平
  input io_bcd,  //模式  0: 脉冲 1:电平

  input [23:0] io_pulseWidth, //脉冲宽度
  input [5:0]  ctrl,

  output [31:0] io_outPort
);

  wire [31:0] en;
  reg catch_d = 0;
  //reg finish_d = 0;
  wire [31:0] pulseOut;  //脉冲形 输出
  wire [31:0] levOut; //电平形 输出
  wire [3:0] bcdOut;
  reg [5:0]  ctrl_d = 0;

  always @ (posedge io_clk) catch_d <= io_catch;

  //assign io_outPort = io_bcd ? {26'd0,ctrl_d} : io_mode ? levOut : pulseOut;
  assign io_outPort = io_mode ? levOut : pulseOut;
  //always @ (posedge io_clk) finish_d <= finish ;
  always @ (posedge io_clk) begin
    if(~io_catch & catch_d) begin
        ctrl_d <= ctrl;
    end
    else if (finish) begin
        ctrl_d <= 6'h00;
    end
    else begin
        ctrl_d <= ctrl_d ;
    end
    
  end

  genvar i;
  generate
    for(i=0; i<32; i=i+1) begin:enGen
      assign en[i] = |ctrl & (i==ctrl-1'd1) & catch_d;
    end
  endgenerate  /*enGen*/

  genvar j;
  generate
    for(j=0; j<32; j=j+1) begin:levGen
      assign levOut[j] = |ctrl_d ?(j == (ctrl_d - 1'd1)) : 1'd0;
    end
  endgenerate  /*levGen*/

  PulseGen #(
    24
  ) outPortPulse[31:0] (
    .io_clk           ( io_clk        ),
    .io_rst           ( io_rst        ),

    .io_en            ( en            ),

    .io_pulseOut      ( pulseOut      ),

    .io_defaultLevel  ( 0             ),
    .io_pulseWidth    ( io_pulseWidth )
  );
endmodule
