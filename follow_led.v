module follow_led #(
   parameter _FOLLOW_CONS = 'd500 ,
   parameter _TWINKLE_WIGHT = 24
) (
    input io_clk ,
    input io_rst_ram ,
    input sig_in ,
    output follow_light
);
    reg [_TWINKLE_WIGHT - 1 : 0] twinkle_cnt ;
    reg sig_in_d1;
    always @ (posedge io_clk) sig_in_d1 <= sig_in ;
    always @ (posedge io_clk or posedge io_rst_ram) begin
        if (io_rst_ram) begin
            twinkle_cnt <= 0;
        end 
        else begin
            twinkle_cnt <=  (sig_in & !sig_in_d1)?  twinkle_cnt + _FOLLOW_CONS :
                            sig_in_d1 ? (twinkle_cnt + 1'b1) :
                            (~|twinkle_cnt)? twinkle_cnt :
                            twinkle_cnt - 1'b1;
        end
 
    end

    assign follow_light = (~|twinkle_cnt) ? 1'b0 : 1'b1 ;
endmodule