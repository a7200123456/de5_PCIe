module pre_processing (
    M,
    N,
    clk,
    beg,
    out,
    out_ready,
    reset,
    
    //observation
    state
    // counting,
    // next_state
);

// this module do the following things:
// 1) take 256-bit M & N
// 2) count the digit of M = n
// 3) use recursive to calculate (2^n)*M mod N
// 4) output the outcome

// ================= parameter definition ===================
    parameter recursive = 1'b0;
    parameter done = 1'b1;
    
// ================= in/out declaration =====================
    // ---------------- input ----------------------------------
    input [255:0] M;
    input [255:0] N;
    input clk;
    input beg;
    input reset;
    
    // ---------------- output --------------------------------- 
    output [255:0] out;
    output out_ready;
    
    //observation
    output  state;
    // output counting;
    // output [1:0] next_state;

// ================= reg/wire declaration ===================
    reg  state;
    reg  next_state;
    reg  counting;
    reg  next_counting;
    reg  recur;
    reg  next_recur;
    reg  firstMod;
    reg  next_firstMod;
    reg  [257:0] MM;
    reg  [257:0] next_MM; 
    reg  out_ready;
    reg  [8:0] recurtime;
    reg  [8:0] next_recurtime;

// ================= combinational part =====================
    // finite state machine
    always@(*) begin
        case (state)       
            recursive: begin
                if (recur == 1) begin
                    next_state = recursive;
                    out_ready = 0;
                end
                else begin
                    next_state = done;
                    out_ready = 1;
                end
            end
            
            done: begin
                if (beg == 0) begin
                    next_state = recursive;
                    out_ready = 0;
                end
                else begin
                    next_state = done;
                    out_ready = 0;
                end
            end
            
            default: begin
                next_state = done;
                out_ready = 0;
            end
        endcase
    end

    // (2) the first time mod N
    // (3) recursive 2M mod N
    always@(*) begin
        if (beg == 0) begin
            next_MM = M;
            next_firstMod = 1;
            next_recur = 1;
            next_recurtime = 0;
        end
        else if (recur == 1 && firstMod == 1) begin  // first time mod N
            if (MM >= N) begin // mod ing
                next_MM = MM - N;
                next_firstMod = 1;
                next_recur = 1;
                next_recurtime = recurtime;

            end
            else begin // finish mod
                next_MM = MM;
                next_firstMod = 0;
                next_recur = 1;
                next_recurtime = recurtime;

            end
        end
        else if (recur == 1 && firstMod == 0) begin // recursive 2M mod N
                if (recurtime < 256 ) begin // recursuve ing
                    if ((MM+MM) >= N) begin // case 1
                        next_MM = MM + MM - N;
                        next_firstMod = 0;
                        next_recur = 1;
                        next_recurtime = recurtime + 9'b1;
                    end
                    else begin // case 2
                        next_MM = MM + MM;
                        next_firstMod = 0;
                        next_recur = 1;
                        next_recurtime = recurtime + 9'b1;
                    end
                end
                else begin // finish recursive
                    if (MM >= N) begin
                        next_MM = MM - N;
                        next_firstMod = 0;
                        next_recur = 0;
                        next_recurtime = recurtime;
                    end
                    else begin
                        next_MM = MM;
                        next_firstMod = 0;
                        next_recur = 0;
                        next_recurtime = recurtime;
                    end
                end
        end
        else begin // all finished
            next_MM = MM;
            next_firstMod = 0;
            next_recur = 0;
            next_recurtime = recurtime;
        end
    end
    
    // out
    assign out = MM[255:0];
    
// ================= sequentail part ========================
always@( posedge clk or posedge reset ) begin

    // reset
    if ( reset == 1 ) begin
        state <= done;
        firstMod <= 1'b1;
        MM <= 0;
        recur <= 1;
        recurtime <= 0;
    end
    // run
    else begin
        state <= next_state;
        firstMod <= next_firstMod;
        MM <= next_MM;
        recur <= next_recur;
        recurtime <= next_recurtime;
    end

end

endmodule
