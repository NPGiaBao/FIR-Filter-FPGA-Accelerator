
`timescale 1ns/1ps

module tb_fir_folded;

    localparam N  = 16;
    localparam DW = 16;
    localparam ACC_W = 2*DW + 5;
    localparam NUM_SAMPLES = 1000;   

    reg                     clk;
    reg                     rst_n;
    reg                     valid_in;
    reg  signed [DW-1:0]    x_in;
    wire                    valid_out;
    wire signed [ACC_W-1:0] y_out;

    
    fir_folded #(.N(N), .DW(DW), .ACC_W(ACC_W)) dut (
        .clk       (clk),
        .rst_n     (rst_n),
        .valid_in  (valid_in),
        .x_in      (x_in),
        .valid_out (valid_out),
        .y_out     (y_out)
    );

    
    always #5 clk = ~clk;

    
    reg [DW-1:0] mem_in [0:NUM_SAMPLES-1];
    integer fout;
    integer k;

    initial begin
        clk   = 0;
        rst_n = 0;
        valid_in = 0;
        x_in  = 0;

        $readmemh("test_input.hex", mem_in);
        fout = $fopen("out_folded.txt", "w");

        
        repeat (2) @(posedge clk);
        rst_n = 1;
        @(posedge clk);

        for (k = 0; k < NUM_SAMPLES; k = k + 1) begin
            
            @(negedge clk);
            x_in     = mem_in[k];
            valid_in = 1;
            @(negedge clk);
            valid_in = 0;

            
            wait (valid_out === 1'b1);
            $fwrite(fout, "%0d\n", y_out);
            @(negedge clk); 
        end

        $fclose(fout);
        $display("HOAN TAT mo phong Folded - %0d mau da xu ly.", NUM_SAMPLES);
        $finish;
    end

    
    initial begin
        $dumpfile("fir_folded.vcd");
        $dumpvars(0, tb_fir_folded);
    end

endmodule
