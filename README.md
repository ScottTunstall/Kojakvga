# Kojakvga

## Intro

This is a walk down memory lane for me, I would have been 23 years old at the time.... how time flies!

My KOJAKVGA unit from 1996 (started 1994) is based on the Amiga's Blitz BASIC and allows DOS Turbo Pascal developers to create video games using the extremely popular (at the time) 320x200x256 VGA mode (also known as Mode 13h) . I had to hand roll my own routines (something I miss dearly) as DirectX didn't exist in 1994 and OpenGL was only on Windows NT, IIRC. This code was published in the SourceWare Archival Group (SWAG) back in the day. I am unsure if its on a Delphi Companion CD, I think it is but can't verify.

The unit supports primitives such as pixel plotting, line drawing & rectangles and advanced game-oriented functionality such as software sprites, sprite scaling and flipping, per-pixel fine scrolling in 4 directions and loading PCX graphic files.

## Requires

Requires Turbo Pascal 6 or 7 to compile and a 32 bit processor to run. Turbo Pascal 7's inline assembler did not support 386 32-bit instructions at the time so to use them I had to insert each opcode as hex into the assembly directly! It was still fun.


