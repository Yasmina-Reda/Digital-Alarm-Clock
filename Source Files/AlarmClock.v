`timescale 1ns / 1ps


module AlarmClock(input clk,rst,U, D, R, L, C, output [6:0]seg, [3:0] anode);
wire up, down, right, left, center,ENTH, ENTM,ENAH, ENAM;
wire [1:0] TH1;
wire [3:0] TH2;
wire [2:0] TM1;
wire [3:0] TM2;
wire clock_out,clock;
wire [1:0]enable_anode;
reg [2:0] state, nextstate;
reg  [3:0]mux_out;
parameter [2:0] N=3'b000 , TH=3'b001, TM=3'b010, AH=3'b011, AM=3'b100;
reg en;
ClockDivider #(5000000) cl( .clk(clk), .rst(rst), .en(1'b1), .clk_out(clk_out));
ClockDivider #(250000) c2( .clk(clk), .rst(rst), .en(1'b1), .clk_out(clock));
Buttons pb( U, D, R, L, C, clk_out, rst,up, down, right, left, center);
Time (clock, rst, en, ENTH, ENTM, updown,TH1,TH2,TM1, TM2);

always @(state)begin
case (state)
N : begin
nextstate <= N;
en=1'b1;
end
default : nextstate <= N;
endcase
end

Binary_Counter #(2,4) count(clock, rst, 1'b1,enable_anode);

 always @ (enable_anode) begin
     case(enable_anode)
        0: mux_out = TM2;
        1: mux_out = TM1;
        2: mux_out = TH2;
        3: mux_out = TH1;
     endcase
     end
     
     always @(posedge clock_out or posedge rst) begin
     if(rst==1)
     mux_out=0;
     else
     state<=nextstate;
     end

BCDto7SEG(1'b1,enable_anode,mux_out,seg,anode);

endmodule