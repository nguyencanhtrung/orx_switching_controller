`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/11/2018 10:44:27 AM
// Design Name: 
// Module Name: tdd_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tdd_top #(parameter ANT_NUM = 8,
                 parameter TRANSIENT_PERIOD = 200, //time for antenna power on = 200ns
                 parameter ARM_CLK = 153.6, // arm clk in MHz 
                 parameter CLK_IN = 245.76  // clk input            
                 )

    (
        input clk_in,
        input rst_n, 
        input i_Tx_en, i_Rx_en,
        input [ANT_NUM*32 - 1:0] i_Rx_data,
        
        output o_Tx_en, o_Rx_en,
        output o_RF_on,
        output reg Tx_stt, Rx_stt,
        output wr_en, rd_en,
        output reg [ANT_NUM*32 - 1:0]  o_Rx_data
    );
    
    localparam time_ARM_CLK = $ceil(CLK_IN/ARM_CLK);
    localparam time_TRANSIENT_PERIOD = $ceil(CLK_IN*TRANSIENT_PERIOD/1000);
    localparam TIME_TX_LOW_TO_HIGH = 168 * time_ARM_CLK;
    localparam TIME_TX_HIGH_TO_LOW = 140 * time_ARM_CLK;
    localparam TIME_RX_LOW_TO_HIGH = 258 * time_ARM_CLK;
    localparam TIME_RX_HIGH_TO_LOW = 40 * time_ARM_CLK;
    localparam TIME_BUFFER_MAX     = $ceil(CLK_IN*0.2); //200ns = 0.2us
    localparam TIME_FOR_TX         = 276 * time_ARM_CLK + TIME_BUFFER_MAX; //(136 = 2(TX ON + RX OFF) - 1*TX OFF)
    
	localparam IDLE		      = 3'b000,
               WAIT_TX        = 3'b001,
               ALL_TX_ON      = 3'b010,
               WAIT_RX        = 3'b011,
               ALL_RX_ON      = 3'b100;  
               
    //declaraiton reg and wire             
    reg [2:0] cur_state, nxt_state;    
    reg [11:0] count, timer;  
    reg [9:0] cnt_for_Tx;  
    reg r_Tx_en;
    reg [9:0] Tx_cnt, Rx_cnt;
    
    //assign wire
    assign o_Tx_en =  i_Tx_en | r_Tx_en;
    assign o_Rx_en = (cur_state == IDLE) ? 0 : ~o_Tx_en;
    assign o_RF_on = i_Tx_en | Tx_stt;
    assign wr_en = i_Tx_en;
    assign rd_en = Tx_stt;
    //count for Tx, Rx status
    always @ (posedge clk_in) begin
        if (~rst_n) begin
            cnt_for_Tx <= 0;
            r_Tx_en <= 0;
            Tx_cnt <= 0;
            Rx_cnt <= 0;
            Tx_stt <= 0;
            Rx_stt <= 0;
        end
        else begin
            if (i_Tx_en) begin
                r_Tx_en <= 1;
                cnt_for_Tx <= 0;
            end
            else begin
                if (cnt_for_Tx < TIME_FOR_TX) cnt_for_Tx <= cnt_for_Tx + 1;
                else r_Tx_en <= 0;
            end
            

            if (cur_state == ALL_TX_ON) begin 
                Tx_stt <= 1;
                Tx_cnt <= 0;
            end
            
            else begin
                if ((Tx_cnt < 2*TIME_TX_HIGH_TO_LOW) && (Tx_stt)) Tx_cnt <= Tx_cnt + 1;
                else begin
                    Tx_cnt <= 0;
                    Tx_stt <= 0;
                end
            end
            
            
            if (cur_state == ALL_RX_ON) begin 
                Rx_stt <= 1;
                Rx_cnt <= 0;
            end            
            else begin
                if ((Rx_cnt < 2*TIME_RX_HIGH_TO_LOW) && (Rx_stt)) Rx_cnt <= Rx_cnt + 1;
                else begin
                    Rx_cnt <= 0;
                    Rx_stt <= 0;
                end
            end           
        end
    end
    
    always @ (i_Rx_en) begin
        if (i_Rx_en) o_Rx_data = i_Rx_data;
    end
    
    
    //-----------------------
    
    always @ (posedge clk_in) begin
        if (~rst_n) begin
            count <= 0;
            cur_state <= IDLE;
        end
        else begin
            count <= count + 1;
            if (count >= timer) begin
                count <= 0;
                cur_state <= nxt_state;
            end
        end
    end   
    
    always @ (i_Tx_en, o_Rx_en, cur_state) begin
        case (cur_state)
            IDLE: begin
                timer = 0;
                if (i_Tx_en) 
                    nxt_state = WAIT_TX;
                else nxt_state = cur_state;
            end
            
            WAIT_TX: begin
                timer = 2*(TIME_TX_LOW_TO_HIGH + TIME_RX_HIGH_TO_LOW) + TIME_BUFFER_MAX;
                nxt_state = ALL_TX_ON;
            end
            
            ALL_TX_ON: begin
                timer = 0;
                if (o_Rx_en) nxt_state = WAIT_RX;
                else nxt_state = cur_state;
            end
            
            WAIT_RX: begin
                timer = 2*(TIME_RX_LOW_TO_HIGH + TIME_TX_HIGH_TO_LOW)+ TIME_BUFFER_MAX;
                nxt_state = ALL_RX_ON;
            end
            
            ALL_RX_ON: begin
                timer = 0;
                if (i_Tx_en) nxt_state = WAIT_TX;
                else nxt_state = cur_state;
            end
        endcase
    end
    
    reg [119:0] stt_cur, stt_nxt;
    always @ (cur_state, nxt_state) begin
        case (cur_state)
            IDLE: stt_cur = "IDLE";
            WAIT_TX: stt_cur = "WAIT_TX";
            ALL_TX_ON: stt_cur = "TX_ON";
            ALL_RX_ON: stt_cur = "RX_ON";
            WAIT_RX: stt_cur = "WAIT_RX";
        endcase
        
        case (nxt_state)
            IDLE: stt_nxt = "IDLE";
            WAIT_TX: stt_nxt = "WAIT_TX";
            ALL_TX_ON: stt_nxt = "TX_ON";
            ALL_RX_ON: stt_nxt = "RX_ON";
            WAIT_RX: stt_nxt = "WAIT_RX";
        endcase        
    end        
               
endmodule
