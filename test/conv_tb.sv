`include "../rtl/cnn_defs.svh"

module conv_tb;

    // DUT Signals
    logic clk = 0;
    logic reset, en;
    logic [DATA_WIDTH-1:0] ifmap [0:IFMAP_SIZE-1][0:IFMAP_SIZE-1];
    logic signed [DATA_WIDTH-1:0] kernel [0:KERNEL_SIZE-1][0:KERNEL_SIZE-1];
    logic [DATA_WIDTH-1:0] ofmap [0:CONV_OFMAP_SIZE-1][0:CONV_OFMAP_SIZE-1];
    logic done;

    // Clock Generation
    always #5 clk = ~clk;

    // DUT instantiation
    conv dut (
        .clk(clk),
        .reset(reset),
        .en(en),
        .conv_ifmap(ifmap),
        .weights(kernel),
        .conv_ofmap(ofmap),
        .conv_done(done)
    );

    // Dump waveform
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, conv_tb);
    end

    // ANSI Color Macros
    `define RED     "\033[1;31m"
    `define GREEN   "\033[1;32m"
    `define YELLOW  "\033[1;33m"
    `define BLUE    "\033[1;34m"
    `define MAGENTA "\033[1;35m"
    `define CYAN    "\033[1;36m"
    `define RESET   "\033[0m"

    task automatic run_convolution_test();
        int f_out; // Declare first, before any statement

        begin
            $display(`BLUE, "Starting Convolution Test...", `RESET);

            en    = 0;
            reset = 1;
            #10;
            reset = 0;
            en    = 1;

            $display("Running with 128x128 input and 3x3 kernel...");

            wait(done);
            #10;

            f_out = $fopen("ofmap.txt", "w");
            if (!f_out) $fatal("Failed to open ofmap.txt for writing");

            foreach (ofmap[i]) begin
                foreach (ofmap[i][j]) begin
                    $fwrite(f_out, "%0d ", ofmap[i][j]);
                end
                $fwrite(f_out, "\n");
            end

            $fclose(f_out);
            $display(`GREEN, "Output feature map saved to ofmap.txt", `RESET);
            $display(`BLUE, "Test Finished.\n", `RESET);
        end
    endtask



    // Stimulus
    initial begin
        // Test 1
        int fd = $fopen("ifmap.txt", "r");
        if (!fd) $fatal("Failed to open ifmap.txt");

        foreach (ifmap[i, j]) begin
            int val;
            if ($fscanf(fd, "%d", val) != 1)
                $fatal(1,"Read error at [%0d][%0d]", i, j);
            ifmap[i][j] = val;
        end

        $fclose(fd);

        kernel = '{
            '{-8'sd1, 8'sd0, 8'sd1},
            '{-8'sd2, 8'sd0, 8'sd2},
            '{-8'sd1, 8'sd0, 8'sd1}
        };
        run_convolution_test();



        $finish;
    end

endmodule
