/* Video module!!!
 * Clock this at 10MHz! 
 * hsync cycle time: 47 
 * bporch cycle time: 59 
 * scan cycle time: 515 
 * fporch cycle time: 14
*/

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

module video(input clk, reset,
             input [1:0] pixelmem_data,
             output reg [16:0] pixelmem_address,
             output reg [1:0] dacout);

reg [31:0] counter; /* Tracks the number of clocks which have elapsed */
reg [16:0] line; /* Tracks which line is currently being scanned */
reg [16:0] x; /* With a clock of 10MHz, we can scan exactly 
                 (51,5*10^-6)/(1/(10*10^6)) = 515 horizontal "pixels"
                 per line. This gives us a resolution of
                 515horizontal x 242 vertical. Pretty usable, right?
                 HOWEVER, such a resolution will not be aesthetically pleasant:
                 Most common display resolutions are proportionate
                 either to 4/3 or 16/9. By using a mixture of trial and error
                 and the method of three, we arrive to the "golden" resolution of
                 320x240 (Of course, we could just consult the Wikipedia
                 article "List of common resolutions", but where's the fun
                 in that?), which is the same resolution as QVGA.*/

/* Video RAM considerations: 
 *
 * RAM dimensions:
 *
 * With this resolution, one will need a 2-bit RAM
 * that can store 320*240 = 76800 words. The Spartan3 family, which I am using
 * to test the design, can easily create such a block RAM. In case RAM
 * dimensions are a problem in your situation, attempt adjusting the system's
 * resolution.
 *
 * Clock:
 *
 * It is highly probable that the device that is going to control the
 * generator will run at a differrent, most probably higher, clock rate than
 * the generator, it is recommended to use a true dual-port RAM.
 *
 */

reg [16:0] pixelmem_address_pre;

always @(posedge clk)
begin
    if(reset == 1'b1)
    begin
            counter <= 32'b0;
            {line, pixelmem_address, 
            pixelmem_address_pre, x} <= 17'b0;
            dacout <= 2'b0;
    end
    else if(reset == 1'b0)
    begin
        /* One clock has elapsed. Increase the counter by one. */
        counter <= counter + 1;
        if(counter <= 32'd46)
            /* Hsync. Time: 4.7μs */
            dacout <= 2'b00;
        else if(counter > 32'd46)
        begin
            if(counter <= 32'd105)
            begin
                /* Back porch. Time: 5.9μs */
                dacout <= 2'b01;
            end
            else if(counter <= 32'd620)
            begin
                    /* Intensity data. Time: 51.5μs */
                    x <= x + 1;
                    if(((x > 17'd320) || (line > 17'd239)))
                    begin
                        pixelmem_address_pre <= pixelmem_address;
                        if(line > 17'd241) begin
                            /* Output the vertical sync signal. */
                            dacout <= 2'b00;
                        end
                        else
                            /* Fill the remaining monitor space with
                             * black "pixels"
                             */
                            dacout <= 2'b01;
                    end
                    else
                    begin
                        pixelmem_address <= (x + pixelmem_address_pre);
                        dacout <= pixelmem_data;
                    end
            end
            else if(counter < 32'd634)
            begin
                /* Front porch. Time: 1.4μs */
                dacout <= 2'b01;
            end
            if(counter == 32'd634)
            begin
                /* We are done. Time to render the next line. */
                x <= 17'd0;
                counter <= 32'd00;
                if(line == 17'd262)
                begin
                    /* We have reached NTSC's line limit.
                     * Time to start over.
                     */
                    line <= 17'd0;
                    pixelmem_address_pre <= 17'd0;
                end
                else
                    line <= line + 1;
            end
        end
    end
end
endmodule //video
