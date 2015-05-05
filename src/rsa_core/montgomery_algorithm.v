module montgomery_algorithm(
    A, B, N, clk, beg,
    out, out_ready, reset
);
//==============parameter definition==================
    parameter O_READY   = 1'b0;
    parameter O_PROCESS = 1'b1;
//===============in/out declaration===================
    input[255:0]  A;
    input[255:0]  B;
    input[255:0]  N;
    input         clk;
    input         beg;
    input         reset;
    output [255:0]        out;
    output        out_ready;
    integer       i;
//==============reg/wire declaration==================
    reg[259:0]    tmp_out;
    reg[259:0]    next_tmp_out;
    reg           out_ready;
    reg[255:0]    AA;
    reg[255:0]    BB;
    reg[256:0]    NN;
    reg[255:0]    next_AA;
    reg[255:0]    next_BB;
    reg[256:0]    next_NN;
    wire[259:0]    q_i256_00; 
    wire[259:0]    q_i256_01; 
    wire[259:0]    q_i256_10;
    wire[259:0]    q_i256_11;
    reg[1:0]      k_i;
    reg[1:0]      q_i;
    reg[8:0]      iter_n;
    wire[8:0]     iter_n1;
    reg[8:0]      next_iter_n;
    //wire [1:0]  first_qi;
//===============combinational part===================
    
    assign iter_n1 = iter_n+9'b1;
    //assign first_qi[0] = AA[0] & BB[0];
    //assign first_qi[1] = (AA[1] & BB[0])^(AA[0] & BB[1]);
    //assign q_i256_00 = tmp_out ;
    //assign q_i256_01 = tmp_out + BB;
    //assign q_i256_10 = q_i256_01 + BB;
    //assign q_i256_11 = q_i256_10 + BB;  
    
    always@(*)begin
        case ({AA[iter_n1],AA[iter_n]})
            2'b00: k_i = tmp_out[1:0];
            2'b01: k_i = tmp_out[1:0]+BB[1:0];
            2'b10: k_i = tmp_out[1:0]+2*BB[1:0];
            2'b11: k_i = tmp_out[1:0]+3*BB[1:0];
        endcase
        case (k_i)
            2'b00: q_i = 2'b00;
            2'b01: q_i = 2'b11;
            2'b10: q_i = 2'b10;
            2'b11: q_i = 2'b01;
        endcase
    end
    
    
    always@(*) begin
        if (beg == 0) begin
            next_tmp_out   = 0;
        end
        else begin
            if(iter_n < 9'd256) begin
            next_tmp_out = (tmp_out +{AA[iter_n1],AA[iter_n]} * BB + q_i*NN) >> 2;
            /*    case ({{AA[iter_n1],AA[iter_n]}})
                
                    2'b00: next_tmp_out   = (tmp_out + q_i*NN) >> 2; 
                    2'b01: next_tmp_out   = (q_i256_01 + q_i*NN) >> 2;
                    2'b10: next_tmp_out   = (q_i256_10 + q_i*NN) >> 2;
                    2'b11: next_tmp_out   = (q_i256_11 + q_i*NN) >> 2;
                    2'b0100: next_tmp_out   = ( q_i256_01) >> 2;
                    2'b0101: next_tmp_out   = ( q_i256_01 + NN) >> 2;
                    2'b0110: next_tmp_out   = ( q_i256_01 + 2*NN) >> 2;
                    2'b0111: next_tmp_out   = ( q_i256_01 + 3*NN) >> 2;
                    2'b1000: next_tmp_out   = ( q_i256_10) >> 2;
                    2'b1001: next_tmp_out   = ( q_i256_10 + NN) >> 2;
                    2'b1010: next_tmp_out   = ( q_i256_10 + 2*NN) >> 2;
                    2'b1011: next_tmp_out   = ( q_i256_10 + 3*NN) >> 2;
                    2'b1100: next_tmp_out   = ( q_i256_11) >> 2;
                    2'b1101: next_tmp_out   = ( q_i256_11 + NN) >> 2;
                    2'b1110: next_tmp_out   = ( q_i256_11 + 2*NN) >> 2;
                    2'b1111: next_tmp_out   = ( q_i256_11 + 3*NN) >> 2;
                endcase*/
            end
            else begin
                if(tmp_out >= NN)
                    next_tmp_out = tmp_out - NN;
                else
                    next_tmp_out = tmp_out;
            end
        end
        
    end
    
    always@(*) begin
        if (beg == 0) begin
            next_iter_n    = 0;
            next_AA = A;
            next_BB = B;
            next_NN = {1'b0,N};
            out_ready = O_PROCESS;
        end
        else begin
            next_iter_n = (iter_n == 9'd260) ?  iter_n : iter_n + 9'd2;
            next_AA = AA;
            next_BB = BB;
            next_NN = NN;
            if(iter_n == 9'd260)
                 out_ready = O_READY;
            else                                 
                 out_ready = O_PROCESS;
        end
    end
    
    assign out = tmp_out[255:0];
//================sequential part=====================
    always@( posedge clk or posedge reset ) begin
        if(reset == 1) begin
            tmp_out   <= 0;
            iter_n    <= 0;
            AA <= 0;
            BB <= 0;
            NN <= 0;
            
        end
        else begin
            iter_n  <= next_iter_n;
            tmp_out <= next_tmp_out;
            AA <= next_AA;
            BB <= next_BB;
            NN <= next_NN;
        end
    end
endmodule
