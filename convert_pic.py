#!/usr/bin/env python
# Copyright (C) 2016 John Tzonevrakis.
# Licensed under the GNU GPL:
#   This file is part of ntsc_gen.
#
#   ntsc_gen is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   ntsc_gen is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with ntsc_gen.  If not, see <http://www.gnu.org/licenses/>.



# Python Kludge to convert any image to a COE file usable by ntsc_gen
# (To be honest, I don't really know python. I just used it here because
# it looks like the right tool for the job, and did not spend any time to 
# learn how to use it properly. Expert pythonistas are expected to proceed with
# caution, or risk losing their sanity ;>)
# Requires PIL

import sys
import csv
from PIL import Image
import warnings
warnings.simplefilter('error', Image.DecompressionBombWarning)
# Usage: conv.py infile outfile.coe

arguments = sys.argv
if len(arguments) != 3:
    print "Usage: conv.py infile outfile"
    exit()
# Everything looks fine; Attempt opening our input image:
infile = Image.open(arguments[1])
# Resize the image to the usable resolution, then convert it to b&w:
infile.thumbnail([320,240], Image.ANTIALIAS)
infile = infile.convert('1')
# Save our image to an array:
imgarray = list(infile.getdata())

# Open our output file, then write boilerplate stuff to it
outfile = open(arguments[2], 'wb')
outfile.write('MEMORY_INITIALIZATION_RADIX=2;\n')
outfile.write('MEMORY_INITIALIZATION_VECTOR=')

# Edit our list so that it contains data acceptable to ntsc_gen
for i in range(0, len(imgarray)):
    if imgarray[i] == 0:
        imgarray[i] = 01 # Black level
    elif imgarray[i] == 255:
        imgarray[i] = 11 # White level
    else:
        print "WARNING: Unknown colorlevel"

# Write our list as a CSV

writer = csv.writer(outfile)
writer.writerow(imgarray)

#...And add the finishing touch[TM]
outfile.write(';')

# We are done. Close the files.

outfile.close()
