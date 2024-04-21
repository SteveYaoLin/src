`timescale 1ns / 1ps
module pwm_pulse # (
    parameter _RAM_WIDTH = 32
) (
    input io_clk,
    input io_rst,

    input io_en,//control bit, keep long
    output io_pulseOut,
    input io_defaultLevel,
    input [_RAM_WIDTH - 1:0] io_pulseWidth,
    input [_RAM_WIDTH - 1:0] io_unaccessWidth,// Number of clocks
    input [_RAM_WIDTH - 1:0] io_pusle_times,
    output reg pulse_valid,
    output reg pulse_busy
);
// wire pulseOut;
wire sig_pul_valid;
reg  unaccess_valid;
reg sig_pul_en;
reg [_RAM_WIDTH - 1:0] cnt_pulse;// 
reg [_RAM_WIDTH - 1:0] cnt_pulse_d1;// 
reg [_RAM_WIDTH - 1:0] cnt_free;// keep clock
reg [_RAM_WIDTH - 1:0] cnt_free_d1;// keep clock
// reg [_RAM_WIDTH - 1:0] pulse_access;// Number of clocks
// reg [_RAM_WIDTH - 1:0] io_unaccessWidth;
reg pwm_dis;
reg pwm_en;
reg pulse_mode;//0 is signal ; 1 is conitnue
 
sigpulse #(
  ._RAM_WIDTH(_RAM_WIDTH)
) sigpulse (
    .io_clk(io_clk),
    .io_rst(io_rst),

  .io_en(sig_pul_en),

  .io_pulseOut(io_pulseOut),
  // output io_delayOut,

  .io_defaultLevel(io_defaultLevel),
  .io_pulseWidth(io_pulseWidth),
  .pulse_valid(sig_pul_valid)
  // input [_RAM_WIDTH - 1:0] io_trigDelay
);
// pulse phase
always @(posedge io_clk or posedge io_rst) begin
    if (io_rst == 1'b1) begin
    pulse_mode <= 1'b0;
    cnt_pulse <= 0;
    sig_pul_en <= 1'b0;
    pulse_busy <= 1'b0;
    pulse_valid <= 1'b0;
    end
    else if (pwm_dis == 1'b1) begin
    pulse_mode <= 1'b0;
    cnt_pulse <= 0;
    pulse_busy <= 1'b0;
    pulse_valid <= (pulse_busy)? 1'b1 : 1'b0;
    // sig_pul_en <= 1'b0;
    end
    else if ((io_en == 1'b1)&&(pwm_en == 0) )begin //starting
        cnt_pulse <= io_pusle_times;
        sig_pul_en <= 1'b1;
        pulse_busy <= 1'b1;
        if (io_pusle_times == 0) begin
            pulse_mode <= 1'b1;
        end
        else begin
            pulse_mode <= 1'b0;
        end
    end 
    else if (sig_pul_en == 1'b1) begin //keep one clock
        sig_pul_en <= 1'b0;
    end
    else if ((unaccess_valid == 1'b1)&&(|cnt_pulse != 0) )begin //create next pulse
        sig_pul_en <= 1'b1;
        cnt_pulse <= cnt_pulse - 1'b1;
        pulse_busy <= 1'b1;
    end
    else if ((pulse_mode == 1'b1)&&(unaccess_valid == 1'b1)) begin // create continue pulse
        sig_pul_en <= 1'b1;
        pulse_busy <= 1'b1;
    end
    else if ((cnt_pulse_d1 == 1)&& (cnt_pulse == 0)&&(unaccess_valid == 1'b1)) begin // final free phase valid
        pulse_busy <= 1'b0; 
        pulse_valid <= 1'b1;
    end
    else if (pulse_valid) begin //keep one clock
        pulse_valid <= 1'b0;
    end
    

end
// unaccess phase
always @(posedge io_clk or posedge io_rst) begin
    if (io_rst == 1'b1) begin
        cnt_free <= 0;
        unaccess_valid <= 0;
    end
    else if (pwm_dis == 1'b1) begin
        cnt_free <= 0;
        unaccess_valid <= 0;
    end
    else if ((sig_pul_valid == 1'b1) && (io_unaccessWidth != 0)) begin
        cnt_free <= io_unaccessWidth;
    end
    else if ((cnt_free == 0 )&& (cnt_free_d1 == 1) ) begin //?
        unaccess_valid <= 1;
    end
    else if (unaccess_valid) begin
        unaccess_valid <= 0;
    end
    else begin
        cnt_free <= (|cnt_free) ? cnt_free - 1'b1 : cnt_free ;
    end
end
// one clock
// reg [_RAM_WIDTH - 1:0]  cnt_free_d1;
always @(posedge io_clk or posedge io_rst) begin
    if (io_rst == 1'b1) begin
        cnt_free_d1 <= 0;
        pwm_en <= 1'b0 ; 

    end
    else begin
        cnt_free_d1 <= cnt_free ;
        pwm_en <= io_en ; 
    end
end
// create final pulse 
always @(posedge io_clk or posedge io_rst) begin
    if (io_rst == 1'b1) begin
        cnt_pulse_d1 <= 0;// 
    end
    else if (unaccess_valid | pulse_valid) begin
        cnt_pulse_d1 <= cnt_pulse ;
    end
    else if (pwm_dis) begin
        cnt_pulse_d1 <= 0;//
    end
end
// create disable
// assign pwm_dis = ~ io_en;
always @(posedge io_clk or posedge io_rst) begin
    if (io_rst == 1'b1) begin
        pwm_dis <= 1'b0;
    end
    else if ((~io_en) & pwm_en) begin
        pwm_dis <= 1'b1;
    end
    else if (pwm_dis == 1'b1) begin
        pwm_dis <= 0;
    end
end

endmodule