`timescale  1ns / 1ps

module tb_MultiChannel_LogicTop;

// MultiChannel_LogicTop Parameters
parameter PERIOD_10M  = 100;
parameter PERIOD_80M  = 12.5;

// MultiChannel_LogicTop Inputs
reg   io_clk                               = 0 ;
reg   io_rst                               = 0 ;
reg   io_rst_ram                           = 0 ;
reg   [0:0]  BUS_CLK                       = 0 ;
reg   [31:0]  BUS_ADDR                     = 0 ;
reg   [3:0]  BUS_BE                        = 0 ;
reg   [31:0]  BUS_DATA_WR                  = 0 ;
reg   io_pulseIn                           = 0 ;

// MultiChannel_LogicTop Outputs
wire  [31:0]  BUS_DATA_RD                  ;
wire  io_fbOut                             ;
wire  [31:0]  io_Out                       ;

initial begin forever #(PERIOD_10M/2)  io_clk=~io_clk; end
initial begin forever #(PERIOD_80M/2)  BUS_CLK=~BUS_CLK; end

reg [8:0] logicRst_80M;
reg [8:0] ramRst_80M;
reg [5:0] logicRst_10M;
reg [5:0] ramRst_10M;
always @ (posedge BUS_CLK) begin
  logicRst_80M <= {logicRst_80M[7:0],io_rst};
  ramRst_80M   <= {ramRst_80M[7:0]  ,io_rst_ram};
end
always @ (posedge io_clk) begin
  logicRst_10M <= {logicRst_10M[4:0],|logicRst_80M};
  ramRst_10M   <= {ramRst_10M[4:0]  ,|ramRst_80M};
end

MultiChannel_LogicTop  u_MultiChannel_LogicTop (
    .io_clk                  ( io_clk              ),
    .io_rst                  ( io_rst              ),
    .io_rst_ram              ( io_rst_ram          ),
    .BUS_CLK                 ( BUS_CLK      [0:0]  ),
    .BUS_ADDR                ( BUS_ADDR     [31:0] ),
    .BUS_BE                  ( BUS_BE       [3:0]  ),
    .BUS_DATA_WR             ( BUS_DATA_WR  [31:0] ),
    .io_pulseIn              ( io_pulseIn          ),

    .BUS_DATA_RD             ( BUS_DATA_RD  [31:0] ),
    .io_fbOut                ( io_fbOut            ),
    .io_Out                  ( io_Out       [31:0] )
);

  task writeBUS;
    input [31:0] addr;
    input [3:0] be;
    input [31:0] data;
    begin : busWirte
      BUS_BE = 3'b0;
      BUS_ADDR = 'h0;
      BUS_DATA_WR = 3'b0;
      #(PERIOD_80M);
      BUS_ADDR = addr;
      BUS_DATA_WR = data;
      #(PERIOD_80M) BUS_BE = be;
      #(PERIOD_80M*2) BUS_BE = 'h0;
      #(PERIOD_80M);
      BUS_ADDR = 'h0;
      BUS_DATA_WR = 3'b0;
      #(PERIOD_80M);
    end
  endtask


task CleanRam;
  begin : CleanRam
    integer i;
    for(i = 'h200;i<'h2d4;i=i+4) begin
      writeBUS(i,'b1111,'d0);
    end
  end
endtask


task p13;
  begin : p13
    io_rst = 1;
    io_rst_ram = 1;
    #(PERIOD_10M*2);
    CleanRam();

    writeBUS('h200,'b0001,'b00000000);  //模式配置 外部脉冲000
    writeBUS('h200,'b1110,'d800 << 1*8);  //触发脉宽
    writeBUS('h204,'b0001,'d4   << 0*8);  //端口总数
    writeBUS('h204,'b1110,'d2000 << 1*8);  //输出脉宽

    writeBUS('h208,'b0111,'d1500 << 0*8);  //反馈延时
    writeBUS('h20c,'b0011,'d1    << 0*8);  //重复次数
    writeBUS('h20c,'b1100,'d100  << 2*8);  //反馈脉宽
    writeBUS('h210,'b0001,'b10    << 0*8);  //反馈高电平，触发低电平
    writeBUS('h214,'b1111,'d0    << 0*8);  //输出默认电平

    writeBUS('h218,'b1111,'b10000   );     //开关 0
    writeBUS('h21c,'b1111,'b100000   );    //开关 1
    writeBUS('h220,'b1111,'b1000000   );   //开关 2
    writeBUS('h224,'b1111,'b10000000   );  //开关 3

    #(PERIOD_10M * 2) io_rst = 0;
    #(PERIOD_10M * 2) io_rst_ram = 0;
    repeat(10) begin
      io_pulseIn = 1 ;
      #(PERIOD_10M * 3000);
      io_pulseIn = 0 ;
      #(PERIOD_10M * 3000);
    end
    io_rst_ram = 1;
    #(PERIOD_10M * 2) io_rst_ram = 0;
  end
endtask

task p14;
  begin : p14
    io_rst = 1;
    io_rst_ram = 1;
    #(PERIOD_10M*2);
    CleanRam();
    
    

    writeBUS('h200,'b0001,'b00000000);  //模式配置 外部脉冲
    writeBUS('h200,'b1110,'d500 << 1*8);  //触发脉宽
    writeBUS('h204,'b0001,'d4   << 0*8);  //端口总数
    writeBUS('h204,'b1110,'d2000 << 1*8);  //输出脉宽

    writeBUS('h208,'b0111,'d1500 << 0*8);  //反馈延时
    writeBUS('h20c,'b0011,'d2    << 0*8);  //重复次数
    writeBUS('h20c,'b1100,'d100  << 2*8);  //反馈脉宽
    writeBUS('h210,'b0001,'b10    << 0*8);  //反馈高电平，触发低电平
    writeBUS('h214,'b1111,'d0    << 0*8);  //输出默认电平

    writeBUS('h218,'b1111,'b10000   );     //开关 0
    writeBUS('h21c,'b1111,'b100000   );    //开关 1
    writeBUS('h220,'b1111,'b1000000   );   //开关 2
    writeBUS('h224,'b1111,'b10000000   );  //开关 3

    #(PERIOD_10M * 2) io_rst = 0;
    #(PERIOD_10M * 20) io_rst_ram = 0;
    repeat(10) begin
      io_pulseIn = 1 ;
      #(PERIOD_10M * 3000);
      io_pulseIn = 0 ;
      #(PERIOD_10M * 3000);
    end
    io_rst_ram = 1;
    #(PERIOD_10M * 2) io_rst_ram = 0;
  end
endtask
task p15;
  begin : p15
    io_rst = 1;
    io_rst_ram = 1;
    #(PERIOD_10M*2);
    CleanRam();

    writeBUS('h200,'b0001,'b00000001);  //模式配置 外部电平 
    writeBUS('h200,'b1110,'d500 << 1*8);  //触发脉宽
    writeBUS('h204,'b0001,'d4   << 0*8);  //端口总数
    // writeBUS('h204,'b1110,'d2000 << 1*8);  //输出脉宽

    writeBUS('h208,'b0111,'d0    << 0*8);  //反馈延时
    writeBUS('h20c,'b0011,'d1    << 0*8);  //重复次数
    writeBUS('h20c,'b1100,'d100  << 2*8);  //反馈脉宽
    writeBUS('h214,'b1111,'d0    << 0*8);  //输出默认电平
    writeBUS('h210,'b0001,'b10    << 0*8);  //反馈高电平，触发低电平

    writeBUS('h218,'b1111,'b10000   );     //开关 0
    writeBUS('h21c,'b1111,'b100000   );    //开关 1
    writeBUS('h220,'b1111,'b1000000   );   //开关 2
    writeBUS('h224,'b1111,'b10000000   );  //开关 3

    #(PERIOD_10M * 2) io_rst = 0;
    #(PERIOD_10M * 20) io_rst_ram = 0;
    repeat(10) begin
      io_pulseIn = 1 ;
      #(PERIOD_10M * 3000);
      io_pulseIn = 0 ;
      #(PERIOD_10M * 3000);
    end
//    io_rst = 1;
//    #(PERIOD_10M * 2) io_rst = 0;
    io_rst_ram = 1;
    #(PERIOD_10M * 2) io_rst_ram = 0;
  end
endtask

task p15_bcd;
  begin : p15_bcd
    io_rst = 1;
    io_rst_ram = 1;
    #(PERIOD_10M*2);
    CleanRam();

    writeBUS('h200,'b0001,'b00000011);  //模式配置 外部bcd 
    writeBUS('h200,'b1110,'d800 << 1*8);  //触发脉宽
    writeBUS('h204,'b0001,'d4   << 0*8);  //端口总数
    // writeBUS('h204,'b1110,'d2000 << 1*8);  //输出脉宽

    writeBUS('h208,'b0111,'d0    << 0*8);  //反馈延时
    writeBUS('h20c,'b0011,'d1    << 0*8);  //重复次数
    writeBUS('h20c,'b1100,'d100  << 2*8);  //反馈脉宽

    writeBUS('h214,'b1111,'b0000000    << 0*8);  //输出默认电平
    writeBUS('h210,'b0001,'b10    << 0*8);  //反馈高电平，触发低电平

    writeBUS('h218,'b1111,'b10000   );     //开关 0
    writeBUS('h21c,'b1111,'b100000   );    //开关 1
    writeBUS('h220,'b1111,'b1000000   );   //开关 2
    writeBUS('h224,'b1111,'b10000000   );  //开关 3

    #(PERIOD_10M * 2) io_rst = 0;
    #(PERIOD_10M * 20) io_rst_ram = 0;
    repeat(10) begin
      io_pulseIn = 1 ;
      #(PERIOD_10M * 3000);
      io_pulseIn = 0 ;
      #(PERIOD_10M * 3000);
    end
    io_rst_ram = 1;
    #(PERIOD_10M * 2) io_rst_ram = 0;
  end
endtask
task p15_soft;//(port_list);
  begin : p15_soft
    io_rst = 1;
    io_rst_ram = 1;
    #(PERIOD_10M*2);
    CleanRam();
    #(PERIOD_10M*2);
    writeBUS('h200,'b0001,'b00000101);  //模式配置 反馈电平H 软件触发，电平
    writeBUS('h204,'b0001,'d4   << 0*8);  //端口总数
    writeBUS('h208,'b0111,'d0    << 0*8);  //反馈延时
    writeBUS('h20c,'b0011,'d1    << 0*8);  //重复次数
    writeBUS('h20c,'b1100,'d00  << 2*8);  //反馈脉宽
    writeBUS('h210,'b0001,'b10    << 0*8);  //反馈高电平，触发低电

    writeBUS('h214,'b1111,'b00000000    << 0*8);  //输出默认电平
    writeBUS('h218,'b1111,'b10000   );     //开关 0
    writeBUS('h21c,'b1111,'b100000   );    //开关 1
    writeBUS('h220,'b1111,'b1000000   );   //开关 2
    writeBUS('h224,'b1111,'b10000000   );  //开关 3

    #(PERIOD_10M * 2) io_rst = 0;
    #(PERIOD_10M * 20) io_rst_ram = 0;
    //第一次软件输出
    writeBUS('h208,'b1000,'d1    << 3*8);  //软件触发开始
    #(PERIOD_10M * 500);
    writeBUS('h208,'b1000,'d2    << 3*8);  //软件触发结束
    #(PERIOD_10M * 20);
    //第2次软件输出
    writeBUS('h208,'b1000,'d1    << 3*8);  //软件触发开始
    #(PERIOD_10M * 500);
    writeBUS('h208,'b1000,'d2    << 3*8);  //软件触发结束
    #(PERIOD_10M * 20);
    //第3次软件输出
    writeBUS('h208,'b1000,'d1    << 3*8);  //软件触发开始
    #(PERIOD_10M * 500);
    // writeBUS('h208,'b1000,'d2    << 3*8);  //软件触发结束
    #(PERIOD_10M * 20);
    //第4次软件输出
    writeBUS('h208,'b1000,'d1    << 3*8);  //软件触发开始
    #(PERIOD_10M * 500);
    writeBUS('h208,'b1000,'d2    << 3*8);  //软件触发结束
    #(PERIOD_10M * 20);
    ////////////////////////////////////
    io_rst_ram = 1;
    #(PERIOD_10M * 2) io_rst_ram = 0;
    
  end
endtask

initial
begin
  //p13();
  //p14();
  //p15();
  //p15_bcd();
  //$finish;
  p15_soft();
end

endmodule
