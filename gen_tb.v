/* Copyright (C) 2016 John Tzonevrakis.
 * Licensed under the GNU GPL:
 *   This file is part of ntsc_gen.
 *
 *   ntsc_gen is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation, either version 3 of the License, or
 *   (at your option) any later version.
 *
 *   ntsc_gen is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with ntsc_gen.  If not, see <http://www.gnu.org/licenses/>.
*/


`timescale 1ns / 1ps
module gen_tb;
    reg clk, reset;
    wire [8:0] pixelmem_address;
    wire [1:0] dacout;
    video vid0(clk, reset, 2'b11, pixelmem_address, dacout);
        initial
        begin
        $display("ntsc_gen testbench. All waveforms will be dumped to the dump.vcd file.");
        $dumpfile("waves.vcd");
        $dumpvars(0, vid0);
        $monitor("Clock: %b Reset: %b \nAddress: %h\n Output: %b\nTime: %d\n",clk,reset,pixelmem_address,dacout,$time);
        clk = 1'b1;
        reset = 1'b1;
        @(posedge clk);
        @(posedge clk);
        reset = 1'b0;
        end
    always
    begin
        forever begin
            #50 clk = !clk;
        end
    end
endmodule //gen_tb
