// Copyright 2025 Maktab-e-Digital Systems Lahore.
// Licensed under the Apache License, Version 2.0, see LICENSE file for details.
// SPDX-License-Identifier: Apache-2.0
//
// Description:
//
// Author: Abdullah Nadeem / Talha Ayyaz
// Date:   13/07/2025


// Comparator 2x2 Module
// Takes a 2x2 matrix of 8-bit unsigned inputs and outputs the maximum value

`include "cnn_defs.svh"

module comparator(
        input   logic [DATA_WIDTH-1:0] input1, input2, input3, input4,
        output  logic [DATA_WIDTH-1:0] max_val
    );

    // Intermediate signals
    logic [DATA_WIDTH-1:0] max_top, max_bottom;

    always_comb begin
        if (input1 > input2) begin
            max_top = input1;
        end else begin
            max_top = input2;
        end
        
        if (input3 > input4) begin
            max_bottom = input3;
        end else begin
            max_bottom = input4;
        end
        
        if (max_top > max_bottom) begin
            max_val = max_top;
        end else begin
            max_val = max_bottom;
        end
    end

endmodule
