# Kojakvga
My KOJAKVGA unit from 1996 (started 1994)  allows DOS Turbo Pascal developers to create video games using the extremely popular (at the time) 320x200x256 VGA mode (also known as Mode 13h) . DirectX didn't exist and OpenGL was only on Windows NT, IIRC. This unit was published in the SourceWare Archival Group (SWAG) back in the day.

The unit supports primitives such as pixel plotting, line drawing & rectangles and advanced game-oriented functionality such as sprite scaling, per-pixel fine scrolling in 4 directions, software sprites & flipping and loading PCX graphic files.

Requires a 32 bit processor. Turbo Pascal 7 did not support 386 32-bit instructions at the time so to use them I had to insert each opcode into the assembly directly! It was still fun.
