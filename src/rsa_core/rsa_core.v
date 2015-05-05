module rsa_core (
    clk,
    reset,
    ready,
    we,
    oe,
    start,
    reg_sel,
    addr,
    data_i,
    data_o//,
    
    // observation
    //state , 
    //counter,
    //pre_ready,
    //beg_pre,
    //pre_state
    
    // signals below are inputs of LA (for observation)
    //clk_o, 
    //reset_o,
    //ready_o,
    //we_o,
    //oe_o,
    //start_o,
    //reg_sel_o,
    //addr_o,
    //data_i_o
);

//==== parameter definition ===============================
    //state
    parameter   we_state = 2'b00;
    parameter   cal_state= 2'b01;
    parameter   oe_state = 2'b10;
    parameter   wait_state = 2'b11;
    
//==== in/out declaration ==================================
    //-------- input ---------------------------
    input clk;
    input reset;
    input we;
    input oe;
    input start;
    input [1:0] reg_sel;
    input [4:0] addr;
    input [7:0] data_i;
    
    //-------- output --------------------------------------
    output reg ready;
    output reg [7:0] data_o;
    
    //-------------observation-----------
    //output [1:0]state;
    //output [8:0]counter;
    //output pre_ready;
    //output beg_pre;
    //output pre_state;
    
    
    // signals below are inputs of LA (for observation)
    //output clk_o;
    //output reset_o;
    //output ready_o;
    //output we_o;
    //output oe_o;
    //output start_o;
    //output [1:0] reg_sel_o;
    //output [4:0] addr_o;
    //output [7:0] data_i_o;

//==== reg/wire declaration ================================
   //assign clk_o = clk;
   //assign reset_o = reset;
   //assign ready_o = ready;
   //assign we_o = we;
   //assign oe_o = oe;
   //assign start_o = start;
   //assign reg_sel_o = reg_sel;
   //assign addr_o = addr;
   //assign data_i_o = data_i;
   
    
    //wire   [7:0] cal_result1 [31:0];
    //wire   [7:0] cal_result2 [31:0];
    //wire   [7:0] cal_result3 [31:0];
    wire   [255:0] next_cal_t;
    wire   [255:0] next_cal_s;
    wire   next_MA_beg;
    wire   [255:0] next_MA_sA     ;
    reg    [255:0] next_MA_sB     ;
    reg    [255:0] next_save;
    reg    [255:0] save;
    wire   [255:0] next_MA_tA     ;
    wire   [255:0] next_MA_tB     ;
    reg   [255:0]  MA_sA     ;
    reg   [255:0]  MA_sB     ;
    reg   [255:0]  MA_tA     ;
    reg   [255:0]  MA_tB     ;
    //wire   [255:0] next_cal_pret  ;
    wire    [255:0] cal_pret  ;
    wire   pre_ready;
    wire   MA_sready;
    wire   MA_tready;
    
    reg    [255:0] cal_t;
    reg    [255:0] cal_s;
    reg    MA_beg;
    reg    [8:0] counter;
    reg    [8:0] next_counter;
    reg    beg_pre;
    
    //reg   [255:0] cal_result0      ;
    //reg   [255:0] next_cal_result0 ;
    
    reg    [255:0] next_a0 ;
    reg    [255:0] next_a1 ;
    reg    [255:0] next_a2 ;
    reg    [255:0] next_a3 ;
    
    
    reg     [1:0]state;
    reg     [1:0]next_state;
    
    reg     [255:0] a0  ;
    reg     [255:0] a1  ;
    reg     [255:0] a2  ;
    reg     [255:0] a3  ;
    
    
    reg     next_ready; 
    reg     next_done;
    reg     done;
    
    reg [7:0] next_data_o;
    integer i;
    
    //observation
    wire pre_state;
    // wire pre_counting;
    // wire [1:0]pre_next_state;
    
//==== combinational part ==================================
   
   //finite state machine
    always@(*) begin
        case(state)
            we_state:begin
                if(we == 0 && start == 1)begin
                    next_ready = 0;
                    next_state = cal_state;
                    beg_pre = 0;
                end
                else begin
                    next_ready = 1;
                    next_state = we_state;
                    beg_pre = 1;
                end
            end        
            cal_state:begin
                if(done == 0)begin
                    next_ready = 0;
                    next_state = cal_state;
                    beg_pre = 1;
                end
                else begin
                    next_ready = 1;
                    next_state = wait_state;
                    beg_pre = 1;
                end
            end
            wait_state: begin
                if (oe == 0) begin
                    next_ready = 1;
                    next_state = wait_state;
                    beg_pre = 1;
                end
                else begin
                    next_ready = 1;
                    next_state = oe_state;
                    beg_pre = 1;
                end
            end
            oe_state:begin
                if(oe == 0)begin
                    next_ready = 1;
                    next_state = we_state;
                    beg_pre = 1;
                end
                else begin
                    next_ready = 1;
                    next_state = oe_state;
                    beg_pre = 1;
                end
            end
            default: begin
                next_ready = 1'b0;
                next_state = 2'b0;
                beg_pre = 1;
            end
        endcase
    end
    
    // ready
    // always@(*)begin
        // if(state == cal_state && done == 0)  next_ready = 1'b0;
        // else next_ready = 1'b1;
    // end
    
    //256bit reg 
    always@(*) begin
        if (state == we_state && we == 1) begin//state == we_state) begin
            //next_a0 = a0; // add
            next_a1 = a1;
            next_a2 = a2;
            next_a3 = a3;
            case(reg_sel)
                2'b00: next_a1[8*addr+:8] = data_i;  
                2'b01: next_a1[8*addr+:8] = data_i;
                2'b10: next_a2[8*addr+:8] = data_i;
                2'b11: next_a3[8*addr+:8] = data_i;
            endcase
        end
        else begin
            //next_a0 = a0; // add
            next_a1 = a1;
            next_a2 = a2;
            next_a3 = a3;
        end
            
            // cal_state:begin
                // for ( i=0; i < 32; i=i+1 )begin
                // next_a0[i] = cal_result0[i];
                
                // end
            // end
            
            // oe_state:begin
                // for ( i=0; i < 32; i=i+1 )begin
                // next_a0[i] = cal_result0[i]; //a0[i]
                
                // end
            // end
            
            // default:begin
                // for ( i=0; i < 32; i=i+1 )begin
                // next_a0[i] = a0[i];
                // next_a1[i] = a1[i];
                // next_a2[i] = a2[i];
                // next_a3[i] = a3[i];
                // end
            // end
        // end
    end
    
    //data_o.
    always@(*) begin
        if (ready == 1) begin//&&state==oe_state)
            if (oe==1)
                next_data_o = a0[8*addr+:8];          
            else 
                next_data_o = data_o;
        end
        else next_data_o = 8'b0;
    end
    
    //calculate
    pre_processing  pre1 (.M(a1),
                          .N(a3),
                           .clk(clk),.beg(beg_pre),.out(cal_pret),.out_ready(pre_ready),
                           .reset(reset)
                           //observation
                           ,.state(pre_state)
                           // ,.counting(pre_counting)
                           // ,.next_state(pre_next_state)
                           );
    
    montgomery_algorithm    MA_s(.A(MA_sA), .B(MA_sB),
                          .N(a3), .clk(clk), .beg(MA_beg), .out(next_cal_s), .out_ready(MA_sready)
                           ,.reset(reset)
                           ); // for S
    montgomery_algorithm    MA_t(.A(MA_tA), .B(MA_tB),
                          .N(a3), .clk(clk), .beg(MA_beg), .out(next_cal_t), .out_ready(MA_tready)
                           ,.reset(reset)
                           ); // for T
                                  
    assign  next_MA_beg = ( ((MA_sready && MA_tready) == 1'b0 || pre_ready == 1'b1) && (pre_state == 1'b1|| pre_ready == 1'b1)&&(counter < 256))? 1'b0 : 1'b1;    
    assign  next_MA_sA = (pre_ready == 1'b1)? cal_pret : cal_t ; 
    //assign  next_MA_sB = pre_ready == 1? 1 : cal_s ;
    always@(*)begin
        if (pre_ready == 1'b1) begin
            next_MA_sB = 1'b1;
            next_save = 1'b1;
        end    
        else if(a2[counter] == 1 && counter < 256) begin
            next_MA_sB = cal_s;
            next_save = cal_s;
        end        
        else begin
            next_MA_sB = MA_sB;
            next_save = save;
        end    
    end
    assign  next_MA_tA = (pre_ready == 1'b1)? cal_pret : cal_t ;
    assign  next_MA_tB = (pre_ready == 1'b1)? cal_pret : cal_t ;
    
    
    
    // put cal_s result into cal_result0
    
     
    always@(*) begin
        if (state != cal_state) begin // change
            next_a0 = a0;
            next_done = 0;
            next_counter = 9'd0;
        end
        else begin
            if (counter == 9'd256) begin
                next_a0 = save;
                next_done = 1;
                next_counter = 9'd0;
                
            end
            else begin
                next_a0 = a0;
                next_done = 0;
                next_counter = (MA_sready == 0 && MA_tready == 0 && MA_beg == 1 && pre_state == 1)? counter + 9'b1: counter;
            end
        end
    end
    
//==== sequential part =====================================  
    always@(posedge clk or posedge reset)
        if (reset == 1) begin
            a0 <= 256'b0;
            a1 <= 256'b0;
            a2 <= 256'b0;
            a3 <= 256'b0;
            //cal_result0 <= 255'b0; 
            cal_t <= 256'b0;
            cal_s <= 256'b0;
            MA_beg<= 1;
            counter <= 0;
            state <= we_state;
            MA_sA <= 256'b0;
            MA_sB <= 256'b0;
            MA_tA <= 256'b0;
            MA_tB <= 256'b0;
            done <= 0;
            data_o <= 8'b0;
            ready <= 1'b1;
            save <= 0;
            //cal_pret <= 255'bx;
        end
        else begin
            a0 <= next_a0;
            a1 <= next_a1;
            a2 <= next_a2;
            a3 <= next_a3;
            //cal_result0 <=next_cal_result0;
            cal_t <= next_cal_t;
            cal_s <= next_cal_s;
            MA_beg<= next_MA_beg;
            counter <= next_counter;
            state <= next_state;
            MA_sA <= next_MA_sA;
            MA_sB <= next_MA_sB;
            MA_tA <= next_MA_tA;
            MA_tB <= next_MA_tB;
            done  <= next_done;
            data_o <= next_data_o;
            ready <= next_ready;
            save <= next_save;
            //cal_pret <= next_cal_pret;
        end
    
endmodule
