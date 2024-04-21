// // todo 总线驱动 无延展
// // todo 逻辑循环
// // todo 总线下发 逻辑复位
// // todo ram 专用复位
// ! BaseLayer
module SyncTrig_LogicTop (
  input io_clk,
  input io_rst,

  input io_rst_ram,

  //BUS
  input  [0:0]  BUS_CLK,
  input  [31:0] BUS_ADDR,
  input  [3:0]  BUS_BE,
  input  [31:0] BUS_DATA_WR,
  output [31:0] BUS_DATA_RD,

  //触发控制
  input io_trigDriv_PulseIn,

  //同步触发端口
  output [7:0] io_syncTrig_PulseOut,
  input  [7:0] io_syncTrig_FbIn,
  output [7:0]  io_follow_led,

  //工作反馈接口
  output [8:0] io_workingFb_PulseOut,//MSB 逻辑反馈,层反馈[7:0] LSB
  //独立控制接口
  output [6:0] io_ind,
  output [6:0] io_ind_led

);

  localparam _PULSEWIDTH_CNT_BITWIDTH = 24 ;
  localparam _TIMER_BITWIDTH = 32 ;

  wire trigDriver_DefLev; //触发驱动 默认电平
  wire [_PULSEWIDTH_CNT_BITWIDTH - 1 : 0] trigDriver_PulseWidthCnt;  //触发驱动 宽度计数
  wire trigDriver_TrigMode;  //触发驱动 模式
  wire trigDriver_Pin;  //触发驱动 pin catch
  wire trigDriver_Bus;  //触发驱动 bus catch
  wire workingMode;  //工作模式 0:计时模式,1:延迟模式

  wire          allEnd;                     //逻辑结束

  wire [15:0]       logicRptNo;     //逻辑循环次数
  wire [(8*3)-1 :0] logicRptDelay; //逻辑循环间隔
  wire               logicRpt_En;           //逻辑 循环en

  wire [7:0]         syncTrig_Trig_En;           //同步触发接口 触发 使能
  wire [7:0]         syncTrig_Trig_DelayEnd;     //同步触发接口 触发 延时结束
  wire [7:0]         syncTrig_Fb_Catch;          //同步触发接口 反馈 catch
  wire [7:0]         syncTrig_Trig_DefLev;       //同步触发接口 触发 默认电平
  wire [7:0]         syncTrig_Fb_DefLev;         //同步触发接口 反馈 默认电平
  wire [7:0]         syncTrig_Fb_DelayEnd;         //同步触发接口 反馈 延时结束
  wire [(_PULSEWIDTH_CNT_BITWIDTH * 8) - 1 : 0] syncTrig_Trig_PulstWidth; //同步触发接口 触发 脉冲宽度
  wire [(_PULSEWIDTH_CNT_BITWIDTH * 8) - 1 : 0] syncTrig_Trig_DelayCnt; //同步触发接口 触发 延时计数
  wire [(_PULSEWIDTH_CNT_BITWIDTH * 8) - 1 : 0] syncTrig_Fb_DelayCnt; //同步触发接口 反馈 延时计数
  wire [(_PULSEWIDTH_CNT_BITWIDTH * 8) - 1 : 0] syncTrig_Fb_PulstWidth; //同步触发接口 反馈 脉冲宽度
  wire [(_TIMER_BITWIDTH * 8) - 1 : 0] syncTrig_Timing1st; //同步触发接口 触发反馈计时 1st
  wire [(_TIMER_BITWIDTH * 8) - 1 : 0] syncTrig_TimingMax; //同步触发接口 触发反馈计时 MAX
  wire [(_TIMER_BITWIDTH * 8) - 1 : 0] syncTrig_TimingMin; //同步触发接口 触发反馈计时 min
  wire [(8*2*8)-1 : 0] syncTrig_PulseCounter;              //同步触发接口 触发计数
  wire [(8*2*8)-1 : 0] syncTrig_FbCounter;                 //同步触发接口 反馈计数

  wire [(_PULSEWIDTH_CNT_BITWIDTH * 7) - 1 : 0] indTrig_PulstWidth; //独立控制接口 脉冲宽度
  wire [(_PULSEWIDTH_CNT_BITWIDTH * 7) - 1 : 0] indTrig_DelayCnt;   //独立控制接口 延时计数
  wire [(8*2 * 7) -1 : 0] indTrig_repNo;                   //独立控制接口 重复次数
  wire [(1 * 7) -1 : 0] indTrig_defLev;                    //独立控制接口 默认电平
  wire [(1 * 7) -1 : 0] indTrig_en;                        //独立控制接口 启动触发


  // wire [(8 * 8) -1 : 0] switchMtx_LayerConf;                //层配置
  wire [(8 * 1) -1 : 0] switchMtx_First;
  wire [(8 * 8) -1 : 0] switchMtx_LayerEnd;
  wire [(8 * 8) -1 : 0] switchMtx_TriggerDelay;
  wire [(8 * 8) -1 : 0] switchMtx_FbDelay;
  wire [(8 * 8) -1 : 0] switchMtx_FallbackCatch;

  wire [7:0]             layer_End;  //层结束
  wire [(8 * 1) -1 : 0]  layerLast;  //指示当前循环为此层最后一次
  wire [(8 * 8) -1 : 0]  layerCfg;   //层配置
  wire [(16 * 8) -1 : 0] layer_repNo;   //层总循环次数

  wire [7:0] BaseLayer;  //基础层 指示
  wire [7:0] switchEnLogic; //用于基础层计数 开关后级
  reg  [31:0] workfinish_cnt;
  reg  allEnd_d1 ;
  wire logicBusy;

  wire syncTrig_MainTrigger = logicRpt_En | (!trigDriver_TrigMode ? trigDriver_Pin : trigDriver_Bus);

  //触发控制端口
  PulseCatch #(
    (24)
  ) trigDriv (
    .io_clk          ( io_clk                    ),
    .io_rst          ( io_rst                    ),
    .io_fb_in        ( io_trigDriv_PulseIn       ),
    .io_fb_catch     ( trigDriver_Pin            ),

    .io_filterCnt    ( trigDriver_PulseWidthCnt  ),
    .io_defaultLevel ( trigDriver_DefLev         )
  );
  reg [15:0] trigDriver_Counter = 'd0;  //触发驱动 计数

  always @(posedge io_clk or posedge io_rst_ram) begin
    if (io_rst_ram) begin
      trigDriver_Counter <= 'd0;
      workfinish_cnt <= 32'h0;
      allEnd_d1<= 1'h0;
    end else begin
      trigDriver_Counter <= trigDriver_Pin ? &trigDriver_Counter ? ~16'd0 : trigDriver_Counter + 1'd1 : trigDriver_Counter;
      allEnd_d1 <= allEnd;
      workfinish_cnt <= (allEnd_d1 & ! allEnd ) ? workfinish_cnt + 1'b1 : workfinish_cnt;
    end
  end

  //逻辑循环
  LogicRepeat LogicRepeat (
    .io_clk       (io_clk),
    .io_rst       (io_rst),
    .io_rptNo     (logicRptNo),
    .io_rptTime   (logicRptDelay),

    .io_logicEnd  (allEnd),
    .io_rptEn     (logicRpt_En),
    .io_mainTrigger (syncTrig_MainTrigger),
    .io_logicBusy   (logicBusy)
  );

  assign allEnd = |(BaseLayer&layer_End);
  //工作反馈接口
  PulseGen #(
    ('d14)
  ) workingFb[8:0] (
    .io_clk          ( io_clk               ),
    .io_rst          ( io_rst                   ),

    .io_en           ( {allEnd,layer_End}    ),

    .io_pulseOut     ( io_workingFb_PulseOut ),
    .io_delayOut     (), //not use

    .io_defaultLevel ( 1'b0                  ),
    .io_pulseWidth   ( 14'd1000              ),
    .io_trigDelay    ()  //not use
  );
  

  //PulseGen #(24) FbDelay[7:0](
  //  .io_clk         (io_clk),
  //  .io_rst         (io_rst),
  //  .io_trigDelay   (syncTrig_Fb_DelayCnt),
  //  .io_en          (syncTrig_Fb_Catch),
  //  .io_delayOut    (syncTrig_Fb_DelayEnd)
  //);

  //同步触发 反馈 端口
  SyncPort #(
    ._RAM_WIDTH        ( _PULSEWIDTH_CNT_BITWIDTH ),
    ._RAM_WIDTH_TIMING ( _TIMER_BITWIDTH          )
  ) syncPort[7:0]  (
    .io_clk         ( io_clk  ),
    .io_rst         ( io_rst      ),
    .io_rst_ram     ( io_rst_ram      ),

    //Triger Port
    .io_pulseEn     ( syncTrig_Trig_En         ),
    .io_pulseOut    ( io_syncTrig_PulseOut     ),
    .io_delayOut    ( syncTrig_Trig_DelayEnd   ),
    .io_pulseWidth  ( syncTrig_Trig_PulstWidth ),
    .io_trigDelay   ( syncTrig_Trig_DelayCnt   ),
    .io_pulseDefLev ( syncTrig_Trig_DefLev     ),
    .follow_led     (io_follow_led),

    //Fallback Port
    .io_fbIn        ( io_syncTrig_FbIn         ),
    .io_fbCatch     ( syncTrig_Fb_Catch        ),
    .io_fbFilterCnt ( syncTrig_Fb_PulstWidth   ),
    .io_fbDefLev    ( syncTrig_Fb_DefLev       ),
    //Fallback delay Port
    .io_Fb_DelayCnt   (syncTrig_Fb_DelayCnt),
    .io_Fb_en         (syncTrig_Fb_Catch),
    .io_Fb_DelayEnd    (syncTrig_Fb_DelayEnd),

    //Timing
    .work_End       ( io_workingFb_PulseOut[8] ),
    .io_timing1st   ( syncTrig_Timing1st       ),
    .io_timingMax   ( syncTrig_TimingMax       ),
    .io_timingMin   ( syncTrig_TimingMin       ),
    .io_pulseCounter( syncTrig_PulseCounter    ),
    .io_fbCounter   ( syncTrig_FbCounter       )
  );

  wire [16*7-1:0] indTrig_Counter;  //独立触发计数

  //独立控制接口
  IndPort #(
    ( _PULSEWIDTH_CNT_BITWIDTH )
  ) IndPort [6:0] (
    .io_clk          ( io_clk             ),
    .io_rst          ( io_rst             ),
    .io_rst_ram      ( io_rst_ram         ),

    .io_pulseEn      ( indTrig_en         ),

    .io_defaultLevel ( indTrig_defLev     ),
    .io_pulseWidth   ( indTrig_PulstWidth ),
    .io_trigDelay    ( indTrig_DelayCnt   ),
    .io_repeatCnt    ( indTrig_repNo      ),

    .io_pulseOut     ( io_ind             ),
    .ind_led         ( io_ind_led         ),
    .ActCounter      ( indTrig_Counter    )
  );

  //层控制
  Layer LayerControl[7:0] (
    .io_clk           ( io_clk                ),
    .io_rst           ( io_rst                ),

    .io_layerCnt      ( layer_repNo            ),
    // .io_pulseEn       ( syncTrig_Trig_En       ),
    .io_fbCatch       ( syncTrig_Fb_Catch |syncTrig_Fb_DelayEnd ),
    .io_delayEnd      ( syncTrig_Trig_DelayEnd ),
    .io_switchEnLogic ( switchEnLogic          ),
    .io_layerCfg      ( layerCfg               ),
    .io_workingMode   ( workingMode            ),
    .io_BaseLayer     ( BaseLayer              ),
    // .io_BaseLayer     ( ~8'b01                  ),
    .io_layerEnd      ( layer_End              ),
    .io_layerLast     ( layerLast              )
  );

  //开关阵列
  SwitchMatrix SwitchMtx(
    .io_mainTrigger        ( syncTrig_MainTrigger    ),//触发信号
    .io_first              ( switchMtx_First         ),//首个
    .io_switchLayerEnd     ( switchMtx_LayerEnd      ),//八个层结束，触发的通道
    .io_switchTriggerDelay ( switchMtx_TriggerDelay  ),//8个延迟结束触发的通道
    .io_switchFbDelay      ( switchMtx_FbDelay       ),//8个反馈结束触发的通道
    .io_switchFallbackCatch( switchMtx_FallbackCatch ),//8个反馈延迟触发的通道

    .io_LayerEnd           ( layer_End               ),//层结束
    .io_LayerLast          ( layerLast               ),//8个层结束信号
    .io_LayerCfg           ( layerCfg                ),//8个层配置信号
    .io_TriggerDelay       ( syncTrig_Trig_DelayEnd  ),//
    .io_FbDelay            ( syncTrig_Fb_DelayEnd    ),//8个通道反馈延迟模式结束信号，1个clk
    .io_FallbackCatch      ( syncTrig_Fb_Catch       ),//8个通道反馈模式信号结束

    .io_BaseLayer          ( BaseLayer               ),
    .io_pulseEn            ( syncTrig_Trig_En        ),
    .io_switchEnLogic      ( switchEnLogic           )
  );

  BUS BUS (
    .io_clk     ( BUS_CLK     ),

    .io_be      ( BUS_BE      ),
    .io_addr    ( BUS_ADDR    ),
    .io_data_o  ( BUS_DATA_RD ),
    .io_data_i  ( BUS_DATA_WR ),

    .RAM_logicRptNo               (logicRptNo   ),
    .RAM_logicRptDelay            (logicRptDelay),
    .RAM_workfinish_cnt           (workfinish_cnt),
    .RAM_trigDriver_DefLev        ( trigDriver_DefLev   ),
    .RAM_trigDriver_Trig          ( trigDriver_Bus      ),
    .RAM_trigDriver_TrigMode      ( trigDriver_TrigMode ),
    .RAM_indTrig_Trig             ( indTrig_en          ),

    .RAM_syncTrig_workingMode  ( workingMode          ),
    .RAM_syncTrig_Trig_First   ( switchMtx_First      ),
    .RAM_syncTrig_Trig_DefLev  ( syncTrig_Trig_DefLev ),
    .RAM_syncTrig_Fb_DefLev    ( syncTrig_Fb_DefLev   ),
    .RAM_indTrig_Trig_DefLev   ( indTrig_defLev       ),

    .RAM_SwMtx_LayerEnd        ( switchMtx_LayerEnd       ),
    .RAM_SwMtx_TriggerDelay    ( switchMtx_TriggerDelay   ),
    .RAM_SwMtx_FbDelay         ( switchMtx_FbDelay        ),
    .RAM_SwMtx_FbCatch         ( switchMtx_FallbackCatch  ),
    .RAM_SwMtx_LayerConf       ( layerCfg                 ),
    .RAM_SwMtc_LayerRepNo      ( layer_repNo              ),
    .RAM_SwMtc_IndRepNo        ( indTrig_repNo            ),
    .RAM_trigDirver_PulseWidth ( trigDriver_PulseWidthCnt ),

    .RAM_syncTrig_Trig_PulseWidth ( syncTrig_Trig_PulstWidth ),
    .RAM_syncTrig_Trig_DelayCnt   ( syncTrig_Trig_DelayCnt   ),
    .RAM_syncTrig_Fb_DelayCnt     ( syncTrig_Fb_DelayCnt     ),
    .RAM_syncTrig_Fb_PulseWidth   ( syncTrig_Fb_PulstWidth   ),

    .RAM_indTrig_PulstWidth      ( indTrig_PulstWidth ),
    .RAM_indTrig_DelayCnt        ( indTrig_DelayCnt   ),

    .syncTrig_Timing1st    ( syncTrig_Timing1st      ),
    .syncTrig_TimingMax    ( syncTrig_TimingMax      ),
    .syncTrig_TimingMin    ( syncTrig_TimingMin      ),
    .syncTrig_PulseCounter ( syncTrig_PulseCounter   ),
    .syncTrig_FbCounter    ( syncTrig_FbCounter      ),
    .logicBusy             ( logicBusy               )
    ,.trigDriver_Counter   ( trigDriver_Counter      )
    ,.indTrig_Counter      ( indTrig_Counter         )
  );

endmodule
