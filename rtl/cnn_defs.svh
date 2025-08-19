// Copyright 2025 Maktab-e-Digital Systems Lahore.
// Licensed under the Apache License, Version 2.0, see LICENSE file for details.
// SPDX-License-Identifier: Apache-2.0
//
// Description:
//
// Author: Abdullah Nadeem & Talha Ayyaz
// Date:   17/07/2025


`ifndef CNN_DEFS_SVH
`define CNN_DEFS_SVH

// -----------------------------------------------------------------------------
// Global CNN Parameters
// -----------------------------------------------------------------------------
parameter int DATA_WIDTH      = 8;
parameter int IFMAP_SIZE      = 256;
parameter int KERNEL_SIZE     = 3;
parameter int STRIDE          = 1;
parameter int PADDING         = 1;

parameter int NUM_CLASSES     = 10;
parameter int FC_BIAS_WIDTH   = 32;
parameter int FC_MAC_WIDTH    = 32;

// -----------------------------------------------------------------------------
// Derived CONV Parameters
// -----------------------------------------------------------------------------

parameter int CONV_OFMAP_SIZE       = (IFMAP_SIZE - KERNEL_SIZE + 2 * PADDING) / STRIDE + 1;
// parameter int MAC_WIDTH             = (DATA_WIDTH * 2) + $clog2(KERNEL_SIZE << 2);               <-- Made for any kernel size -->
parameter int CONV_COUNTER_SIZE     = $clog2(CONV_OFMAP_SIZE);

typedef enum logic [1:0] {
    CONV_IDLE,
    CONV_PROCESS,
    CONV_DONE
} conv_state_t;

// -----------------------------------------------------------------------------
// Derived MAC Parameters
// -----------------------------------------------------------------------------

parameter int MAC_PRODUCT_COUNT     = KERNEL_SIZE * KERNEL_SIZE;
// parameter int MAC_PRODUCT_COUNT     = (KERNEL_SIZE == 3) ? 9 : 25;
parameter int MAC_PRODUCT_WIDTH     = DATA_WIDTH << 1;
parameter int MAC_RESULT_WIDTH      = MAC_PRODUCT_WIDTH + $clog2(MAC_PRODUCT_COUNT);

// -----------------------------------------------------------------------------
// Derived POOL Parameters
// -----------------------------------------------------------------------------

parameter int POOL_OFMAP_SIZE       = CONV_OFMAP_SIZE >> 1;
// parameter int POOL_OFMAP_SIZE       = 2;
parameter int POOL_PIXEL_COUNT      = POOL_OFMAP_SIZE * POOL_OFMAP_SIZE;
// parameter int POOL_PIXEL_COUNT      = 7;

parameter int POOL_COUNTER_SIZE     = $clog2(POOL_OFMAP_SIZE);            
// parameter int POOL_COUNTER_SIZE     = $clog2(4);

typedef enum logic [1:0] {
    POOL_IDLE,
    POOL_PROCESS,
    POOL_DONE
} pool_state_t;

// -----------------------------------------------------------------------------
// Derived FC Parameters
// -----------------------------------------------------------------------------

// FSM states
typedef enum logic [1:0] {
    FC_IDLE,
    FC_PROCESS,
    FC_DONE
} fc_state_t;

parameter int FC_COUNTER_SIZE       = $clog2(POOL_PIXEL_COUNT);
parameter int FC_CLASS_COUNTER_SIZE = $clog2(NUM_CLASSES);

`endif