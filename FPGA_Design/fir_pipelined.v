
module fir_pipelined #(
    parameter N  = 16,      
    parameter DW = 16       
)(
    input                             clk,
    input                             rst_n,
    input                             valid_in,
    input  signed [DW-1:0]            x_in,
    output                            valid_out,
    output signed [2*DW+3:0]          y_out     
);

    localparam H = N/2;   

    
    reg signed [DW-1:0] x_shift [0:N-1];
    integer i;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < N; i = i + 1) x_shift[i] <= 0;
        end else if (valid_in) begin
            x_shift[0] <= x_in;
            for (i = 1; i < N; i = i + 1) x_shift[i] <= x_shift[i-1];
        end
    end

    
    reg signed [DW-1:0] h_mem [0:H-1];
    initial $readmemh("fir_coeff_half.mem", h_mem);

    
    reg signed [2*DW:0] mult_r [0:H-1];         // 2*DW+1 bit
    always @(posedge clk) begin
        for (i = 0; i < H; i = i + 1)
            mult_r[i] <= (x_shift[i] + x_shift[N-1-i]) * h_mem[i];
    end

    /
    reg signed [2*DW+1:0] sum4 [0:3];           // 2*DW+2 bit
    always @(posedge clk) begin
        for (i = 0; i < 4; i = i + 1)
            sum4[i] <= mult_r[2*i] + mult_r[2*i+1];
    end

    
    reg signed [2*DW+2:0] sum2 [0:1];           // 2*DW+3 bit
    always @(posedge clk) begin
        sum2[0] <= sum4[0] + sum4[1];
        sum2[1] <= sum4[2] + sum4[3];
    end

    
    reg signed [2*DW+3:0] y_r;                  // 2*DW+4 bit
    always @(posedge clk) begin
        y_r <= sum2[0] + sum2[1];
    end
    assign y_out = y_r;

    
    reg [4:0] valid_pipe;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) valid_pipe <= 5'b0;
        else        valid_pipe <= {valid_pipe[3:0], valid_in};
    end
    assign valid_out = valid_pipe[4];

endmodule
