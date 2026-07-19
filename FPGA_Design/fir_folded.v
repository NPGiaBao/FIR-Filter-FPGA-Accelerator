
module fir_folded #(
    parameter N     = 16,              // so tap bo loc
    parameter DW    = 16,              // do rong bit du lieu vao / he so
    parameter ACC_W = 2*DW + 5         // do rong bit accumulator, du chong tran cho N<=16
)(
    input                            clk,
    input                            rst_n,
    input                            valid_in,
    input  signed [DW-1:0]           x_in,
    output reg                       valid_out,
    output reg signed [ACC_W-1:0]    y_out
);

   
    reg signed [DW-1:0] h_mem [0:N-1];
    initial $readmemh("fir_coeff_full.mem", h_mem);

   
    reg signed [DW-1:0] x_mem [0:N-1];
    integer i;

    
    localparam IDLE = 2'd0, COMPUTE = 2'd1, DONE = 2'd2;
    reg [1:0]            state;
    reg [$clog2(N):0]    cnt;          // dem 0..N-1

    reg signed [ACC_W-1:0] acc;

  
    wire signed [2*DW-1:0] mult_comb = h_mem[cnt] * x_mem[cnt];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state     <= IDLE;
            valid_out <= 1'b0;
            cnt       <= 0;
            acc       <= 0;
            y_out     <= 0;
            for (i = 0; i < N; i = i + 1) x_mem[i] <= 0;
        end else begin
            valid_out <= 1'b0;   // mac dinh moi chu ky, chi len 1 o trang thai DONE

            case (state)
                
                IDLE: begin
                    if (valid_in) begin
                        // dich mau moi vao dau mang, cac mau cu doi xuong 1 vi tri
                        for (i = N-1; i > 0; i = i - 1)
                            x_mem[i] <= x_mem[i-1];
                        x_mem[0] <= x_in;

                        acc   <= 0;
                        cnt   <= 0;
                        state <= COMPUTE;
                    end
                end

                
                COMPUTE: begin
                    acc <= acc + mult_comb;
                    if (cnt == N-1)
                        state <= DONE;
                    else
                        cnt <= cnt + 1;
                end

                
                DONE: begin
                    y_out     <= acc;
                    valid_out <= 1'b1;
                    state     <= IDLE;
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule
