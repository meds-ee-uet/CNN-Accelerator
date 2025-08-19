// Copyright 2025 Maktab-e-Digital Systems Lahore.
// Licensed under the Apache License, Version 2.0, see LICENSE file for details.
// SPDX-License-Identifier: Apache-2.0
//
// Description:
//
// Author: Abdullah Nadeem & Talha Ayyaz
// Date: 14/07/2025

`include "cnn_defs.svh"

module maxpool (
    input   logic   clk,
    input   logic   reset,
    input   logic   en,
    input   logic   [DATA_WIDTH-1:0] ifmap [0:CONV_OFMAP_SIZE-1][0:CONV_OFMAP_SIZE-1],
    output  logic   [DATA_WIDTH-1:0] ofmap [0:(CONV_OFMAP_SIZE/2)-1][0:(CONV_OFMAP_SIZE/2)-1],
    output  logic   done_pool
);

    localparam int OFMAP_HEIGHT = CONV_OFMAP_SIZE / 2;
    localparam int OFMAP_WIDTH = CONV_OFMAP_SIZE / 2;

    logic [DATA_WIDTH-1:0] window [0:1][0:1];
    logic [DATA_WIDTH-1:0] max_val;
    logic [POOL_COUNTER_SIZE-1:0] out_row;
    logic [POOL_COUNTER_SIZE-1:0] out_col;
    logic maxpool_done;
    logic processing_valid;

    pool_state_t state, next_state;

    // Comparator Unit
    comparator comp_inst (
        .in(window),
        .out(max_val),
        .maxpool_done(maxpool_done)
    );

    // FSM State Register
    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            state <= POOL_IDLE;
        else
            state <= next_state;
    end

    // FSM Next State Logic
    always_comb begin
        next_state = state;
        case (state)
            POOL_IDLE: begin
                if (en)
                    next_state = POOL_PROCESS;
            end
            POOL_PROCESS: begin
                if (maxpool_done && out_row == OFMAP_HEIGHT - 1 && out_col == OFMAP_WIDTH - 1)
                    next_state = POOL_DONE;
                else
                    next_state = POOL_PROCESS;
            end
            POOL_DONE:
                next_state = POOL_DONE;
            default:
                next_state = POOL_IDLE;
        endcase
    end

    // Output Row/Column Counter Logic
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            out_row <= 0;
            out_col <= 0;
        end
        else if (state == POOL_PROCESS) begin
            if (out_col == OFMAP_WIDTH - 1) begin
                out_col <= 0;
                out_row <= out_row + 1;
            end
            else begin
                out_col <= out_col + 1;
            end
        end
    end

    // Load 2x2 Window
    always_comb begin
        if (state == POOL_PROCESS) begin
            window[0][0] = ifmap[(out_row << 1)][(out_col << 1)];
            window[0][1] = ifmap[(out_row << 1)][(out_col << 1) + 1];
            window[1][0] = ifmap[(out_row << 1) + 1][(out_col << 1)];
            window[1][1] = ifmap[(out_row << 1) + 1][(out_col << 1) + 1];
        end
        else begin
            window[0][0] = 0;
            window[0][1] = 0;
            window[1][0] = 0;
            window[1][1] = 0;
        end
    end

    // Processing Valid Signal
    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            processing_valid <= 0;
        else
            processing_valid <= (state == POOL_PROCESS);
    end

    // Output Storage
    always_ff @(posedge clk) begin
        if (state == POOL_PROCESS && maxpool_done)
            ofmap[out_row][out_col] <= max_val;
    end

    // Done Signal
    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            done_pool <= 0;
        else if (state == POOL_DONE)
            done_pool <= 1;
        else
            done_pool <= 0;
    end

endmodule