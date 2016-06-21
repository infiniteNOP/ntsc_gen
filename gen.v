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
	     output reg [8:0] pixelmem_address,
	     output reg [1:0] dacout);

reg [31:0] counter;
reg [8:0] addy;

always @(posedge clk)
begin
	if(reset == 1'b1)
	begin
	        counter <= 32'b0;
        	{addy, pixelmem_address} <= 9'b0;
        	dacout <= 2'b0;
	end
	else if(reset == 1'b0)
	begin
		counter <= counter + 1;
		if(counter <= 32'd46)
			dacout <= 2'b00;
		else if(counter > 32'd46)
		begin
			if(counter <= 32'd105)
			begin
				dacout <= 2'b01;
			end
			else if(counter <= 32'd620)
			begin
				if(addy < 9'd242)
				begin
					pixelmem_address <= addy;
					dacout <= pixelmem_data;
				end
				else if(addy > 9'd242)
				begin
					dacout <= 2'b00;
					if(addy == 9'd261)
					begin
						pixelmem_address <= addy;
						addy <= 8'b00;
					end
				end
			end
			else if(counter < 32'd634)
			begin
				dacout <= 2'b00;
			end
			if(counter == 32'd634)
			begin
				addy <= addy + 1;
				counter <= 32'd00;
			end
		end
	end
end
endmodule //video
