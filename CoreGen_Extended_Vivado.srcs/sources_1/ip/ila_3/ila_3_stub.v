// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
// Date        : Sat Mar  9 21:42:27 2019
// Host        : DESKTOP-TN1C6Q5 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               c:/Users/Trevor/Documents/CyberCore/CoreGen_Extended_Vivado.srcs/sources_1/ip/ila_3/ila_3_stub.v
// Design      : ila_3
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a35tcpg236-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "ila,Vivado 2018.3" *)
module ila_3(clk, probe0)
/* synthesis syn_black_box black_box_pad_pin="clk,probe0[6:0]" */;
  input clk;
  input [6:0]probe0;
endmodule
