`timescale 1ns / 1ps

module FSM(input clk, rst, up, down, right, left, center, Z, [5:0] secs, output adjust, output reg [4:0] EN, output led);
    //States Encoding 
    parameter [2:0] TH = 3'b000, TM = 3'b001, AH = 3'b010, AM = 3'b011, Clock = 3'b100, Alarm = 3'b101;
    reg [2:0] state, nextState; 
    
    
    assign signal = up | down | left | right | center; 
// Next state logic    
    always @ * begin
        case(state)
            TH: begin 
                if(right) nextState = TM; 
                else if(left) nextState = AM; 
                else if(center) nextState = Clock; 
                else nextState = TH; 
                end 
            TM: begin 
                if(right) nextState = AH; 
                else if(left) nextState = TH; 
                else if(center) nextState = Clock; 
                else nextState = TM; 
                end             
            AH: begin 
                if(right) nextState = AM; 
                else if(left) nextState = TM; 
                else if(center) nextState = Clock; 
                else nextState = AH; 
                end 
            AM: begin 
                if(right) nextState = TH; 
                else if(left) nextState = AH; 
                else if(center) nextState = Clock; 
                else nextState = AM; 
                end 
            Clock: begin
            // but if go from adjust to clock alarm doesn't go off
                if(Z && secs == 0) nextState = Alarm;
                 else if(center) nextState = TH; 
                  else nextState = Clock; 
                  end 
            Alarm: begin
                if(signal) nextState = Clock;
                else nextState = Alarm;  
            end  
        endcase 
    end
    
// current state logic    
    always @ (posedge clk or posedge rst) begin 
        if(rst) 
            state <= TH; 
        else
            state <= nextState; 
    end
    
// output logic    
    assign adjust = (state == Clock || state == Alarm)? 0 : 1;
    assign led = (state == Alarm)? 1 : 0;
    
    always @ * begin
        case(state)
            TH: EN = 5'b10000;
            TM: EN = 5'b01000;            
            AH: EN = 5'b00101; 
            AM: EN = 5'b00011;
            Clock: EN = 5'b00001;
            Alarm: EN = 5'b00001;
        endcase 
    end
endmodule
