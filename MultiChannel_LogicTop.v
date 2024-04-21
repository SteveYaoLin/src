module MultiChannel_LogicTop (
  input io_clk,
  input io_rst,
  input io_rst_ram,

  //BUS
  input  [0:0]  BUS_CLK,
  input  [31:0] BUS_ADDR,
  input  [3:0]  BUS_BE,
  input  [31:0] BUS_DATA_WR,
  output [31:0] BUS_DATA_RD,

  input io_pulseIn,
  output io_fbOut,
  output [31:0] io_follow_led,
  output [31:0] io_Out
);
  wire TrigDrive_Catch;    //触发驱动 catch
  wire [23:0] TrigDrive_Cnt;      //触发驱动 脉宽
  wire TrigDrive_DefLev;   //触发驱动 默认电平

  wire TrigMod; //触发模式 0: 外部 1: bus
  wire RAM_busTrig; // 总线触发
  wire RAM_busfinish ;//总线结束			


  wire [15:0] catchCounter; //触发计数
  wire [15:0] fbCounter;    //反馈计数
  wire [(16*32)-1:0] outCounter; //输出计数

  wire [31:0] RAM_defLev;   //输出默认电平
  wire [(32*32)-1:0] RAM_Switch;  //开关
  wire [23:0] TrigDriveDelay; //反馈 延时

  wire RAM_mode;  //模式 0:脉冲 1:电平
  wire RAM_bcd;
  wire [23:0]RAM_pulseWidth;   //脉冲输出 脉宽
  wire [15:0] RptNo; //重复次数
  wire [5:0]  portNo; //端口总数

  wire [5:0]  ctrl; //输出控制
  wire [31:0] ctrlOut;   //内部输出信号  开关前
  wire [31:0] Pulus_lev_Out;
  wire Fb_En;   //触发反馈 使能
  wire Fb_DefLev;   //触发反馈 默认电平
  wire [15:0] RAM_fbWidth; //触发反馈 脉宽
  reg finish_triger_Drive = 0;
  wire pulseIn_16r ;
  reg pulseIn_17r  = 0;
  wire finish  = TrigMod ? RAM_busfinish : finish_triger_Drive ;
  wire mainEN  = TrigMod ? RAM_busTrig : TrigDrive_Catch;
  
  PulseCatch #(
    24
  ) TrigDrive (
    .io_clk      (io_clk),
    .io_rst      (io_rst),
    .io_fb_in    (io_pulseIn),
    .io_fb_catch (TrigDrive_Catch),

    .io_filterCnt    (TrigDrive_Cnt),
    .io_defaultLevel (TrigDrive_DefLev)
  );
  Filter #(
    16                )
  SignalFilter(
    .io_clk       (io_clk                    ),
    .io_rst       (io_rst      ),
    .io_in        (io_pulseIn ^ TrigDrive_DefLev),
    .io_out       (pulseIn_16r        ),
    .io_filterCnt ('d16              )
  );
  always @(posedge io_clk ) pulseIn_17r <= pulseIn_16r ;
  always @(posedge io_clk )begin
    if (~pulseIn_17r & pulseIn_16r ) begin
      finish_triger_Drive <= 1'b1;
    end 
    else begin
      finish_triger_Drive <= 1'b0;
    end  
  end
  PulseGen #(
    16
  ) TriggerFb (
    .io_clk      (io_clk),
    .io_rst      (io_rst),

    .io_en       (Fb_En),

    .io_pulseOut (io_fbOut),
    .io_delayOut (),  //not use

    .io_defaultLevel (Fb_DefLev),
    .io_pulseWidth (RAM_fbWidth),
    .io_trigDelay ()//not use
  );

  MC_Delay MC_Delay (
    .io_clk (io_clk),
    .io_rst (io_rst),

    .io_catch (mainEN),
    .io_Delay (TrigDriveDelay),
    .io_delayEnd (Fb_En)
  );

  MC_Ctrl MC_Ctrl (
  .io_clk     (io_clk         ),
  .io_rst     (io_rst         ),

  .io_catch   (mainEN),

  .io_RptNo   (RptNo          ),
  .portNo     (portNo         ),

  .ctrl       (ctrl           )
);
  MC_outCtrl MC_outCtrl (
    .io_clk   (io_clk         ),
    .io_rst   (io_rst         ),

    .io_catch (mainEN),
    .finish   (finish),
    .io_mode  (RAM_mode),  //模式  0: 脉冲 1:电平
    .io_bcd   (RAM_bcd),

    .io_pulseWidth (RAM_pulseWidth), //脉冲宽度
    .ctrl          (ctrl),

    .io_outPort    (ctrlOut)
  );

  MC_SwitchMatrix MC_SwitchMatrix (
    .io_portSig  (ctrlOut),
    .io_defLev   (RAM_defLev),
    .io_Switch   (RAM_Switch),
    .io_bcd   (RAM_bcd),
    .io_portOut  (io_Out)
  );
  //assign io_Out =  Pulus_lev_Out ;

    follow_led  #(
     'd500 ,
     24
  ) 
  follow_led[31:0] (
      .io_clk(io_clk) ,
      .io_rst_ram   (io_rst_ram) ,
      .sig_in       (io_Out^RAM_defLev) ,
      .follow_light (io_follow_led)
  );
  MC_Counter MC_Counter(
    .io_clk (io_clk),
    .io_rst (io_rst_ram),
    .io_mainEN (mainEN),
    .io_catch (TrigDrive_Catch),
    .io_fbEn  (io_fbOut^Fb_DefLev),
    .ctrl     (ctrl),

    .io_catchCounter  (catchCounter),
    .io_fbCounter     (fbCounter),
    .io_outCounter    (outCounter)
  );

  MC_BUS BUS(
    .io_clk (BUS_CLK),


    .io_be     (BUS_BE),
    .io_addr   (BUS_ADDR),
    .io_data_i (BUS_DATA_WR),
    .io_data_o (BUS_DATA_RD),

    .RAM_mode (RAM_mode),
    .RAM_bcd  (RAM_bcd),
    .RAM_TrigMod (TrigMod),
    .RAM_TrigDeflev (TrigDrive_DefLev),
    .RAM_FbDeflev (Fb_DefLev),

    .RAM_TrigPulseWidth (TrigDrive_Cnt),
    .RAM_pulseWidth (RAM_pulseWidth),
    .RAM_fbWidth    (RAM_fbWidth),
    .RAM_portNo     (portNo),
    .RAM_fbDelay    (TrigDriveDelay),
    .RAM_busTrig (RAM_busTrig),
    .RAM_busfinish(RAM_busfinish),
    .RAM_rptNo   (RptNo),
    .RAM_defLev  (RAM_defLev),

    .RAM_SW      (RAM_Switch),
    //end RAM

    .catchCounter (catchCounter),
    .fbCounter   (fbCounter),
    .outCounter   (outCounter)
  );
endmodule
