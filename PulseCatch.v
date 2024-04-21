/** 同步反馈接口
*  反馈脉冲宽度:1us ~ 1s 可设置(每路独立设置,脉冲宽度作为判宽滤波使用);
*  反馈电平极性:可设置(高/低电平);
*  反馈输入计数:每个接口具有同步反馈输入计数功能.
*
*  ! 两次脉冲需间隔 3clk 以上
*/
module PulseCatch #(
  parameter _RAM_WIDTH = 32
)(
  input io_clk,
  input io_rst,
  input io_fb_in,
  output io_fb_catch,

  input [_RAM_WIDTH - 1:0] io_filterCnt,
  input io_defaultLevel
);

  wire filterOut;
  reg filterOut_d;
  // reg defaultLevel_d;
  wire localRst;
  reg localRst_d;

  always @ (posedge io_clk) begin
    filterOut_d <= filterOut;
    // defaultLevel_d <= io_defaultLevel;
    localRst_d <= localRst;
  end

  assign localRst = io_rst | io_fb_catch ;
  assign io_fb_catch = filterOut & !filterOut_d;

  Filter #(
    ._RAM_WIDTH   (_RAM_WIDTH                )
  )SignalFilter(
    .io_clk       (io_clk                    ),
    .io_rst       (localRst|localRst_d       ),
    .io_in        (io_fb_in ^ io_defaultLevel),
    .io_out       (filterOut                 ),
    .io_filterCnt (io_filterCnt              )
  );

endmodule
