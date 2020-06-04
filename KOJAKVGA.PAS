(*
****************************************************************

TITLE    : KOJAKVGA VERSION 3.5.1

FILENAME : KOJAKVGA.PAS

AUTHOR   : SCOTT TUNSTALL B.Sc (aka Lt. Kojak)

EMAIL    : tunstals@email.msn.com
           tunstals@hotmail.com

FINISH   : REV 3.1:  18TH AUGUST 1996 (A lot of bugs were left
DATE       in this version: You might have it in the SWAG if
	   you're unlucky!)

	   3.2:  26TH OCTOBER 1996

	   3.3:  24TH NOVEMBER 1996 ( 3.2 w/ bug fixes &
					  optimisations)

           3.4:  AUGUST 13TH 1997 (a year on already!) This
                 version employs the new PCXcache unit.

           3.5:  AUGUST 20TH 1998 (2 years on.. I added bits just
                 for my Boulderdash game)

TESTING  : TESTED ON A INTEL P133 W/ CIRRUS LOGIC 5446 PCI
	   GRAPHICS CARD & 24MB OF RAM.

           3.5.1 TESTED ON P2-400, 192 MB RAM, W/ STB 4400 TNT CARD





THIS IS PROBABLY THE LAST [TP7] KOJAKVGA YOU WILL SEE.
I HAVE TAKEN THE DOS VERSION OF KOJAKVGA AS FAR AS IT CAN GO,
I THINK.


IF ANY OF YOU OUT THERE HAVE USED KOJAKVGA IN YOUR OWN
PROGRAMS, OR EVEN RIPPED MY CODE (lamer! - just kidding)
THANK YOU.

      Regards,
              Scott Tunstall.

****************************************************************
*)



{
LEGAL STUFF:

No unauthorised modification, extraction or reproduction of any
part of this unit source allowed, except for inspection
purposes.

You are allowed to compile this unit and use it in tandem with
your own software, as long as you mention my name and KOJAKVGA
in the credits.

In the event you discover any bugs, you are permitted to fix
them, as long as you post the fixes to wherever you got this from.



DISCLAIMER:
-----------

Use this unit at your OWN RISK. If your PC dies after using
KOJAKVGA, don't blame me. KOJAKVGA works fine on my PC.
(But then again, I would say that, cos if I didn't, no-one
would use this would they? But it works!)
}






{$A+,B-,E+,F-,G+,N+,Q-,R-,S-,X+}

UNIT KOJAKVGA;

INTERFACE



Const

      VGA_ADDR                = ptr($a000,0);

{ These rather old chappies are present in NEWGRAPH - BUT,
  because the window sizes can vary, GetMaxX and GetMaxY are
  now (whoo!) functions which return the CURRENT WINDOW SIZE -
  NOT your physical VGA screen size (previously 319,199)
}

      GetMaxColour            = 255;
      MaxColours              = 256;

      Int1fFont               = 0;
      Int43Font               = 1;
      StandardVGAFont         = 1;
      Font8x8                 = 1;
      Font8x14                = 2;
      Font8x8dd               = 3;
      Font8x8ddHigh           = 4;
      AlphaAlternateFont      = 5;
      FontAlpha               = 5;
      Font8x16                = 6;
      Font9x16                = 7;
      FontRomAlt              = 7;





{ Refer to NEWGRAPH for definition of these structs (if it's not
  obvious enough already) }

Type
PaletteType = record
   RedLevel,
   GreenLevel,
   BlueLevel :   Array[0..MaxColours-1] of Byte;
end;




{ First 2 fields aren't used in disk file, which is a waste of
  course, but I could always use them to hold the text 'FONT'
  as a type identifier. And f**k up compatibility.
}

FontType = record
   FontSeg       : Word;
   FontOfs       : Word;
   FontWidth     : Byte;
   FontByteWidth : Byte;
   FontHeight    : Byte;
   FontChars     : Byte;
End;





{
Format of shapes stored in memory. Just in case I change it, like :)
Added 23rd November 1996 for v3.3
}


ShapeMemFmt = record
     ShapeWidth   : Byte;
     ShapeHeight  : Byte;
end;



{ Format of Shapes saved on disk - type created Nov 8th 1996.


	       SHAPES FORMAT HAS BEEN EXTENDED

  Now Shape objects can have attached palettes.
  (Believe me, it took a _LOT_ of fannying about to implement
  the attached palette stuff. It wasn't difficult or anything,
  just tedious! :). I reckon it's time to create a new
  shape format.

  This format STILL can't accommodate shape objects that
  are larger than 255 x 255. What's the point? The VGA screen
  is only 320 x 200, and frankly who needs single sprites that
  large? (Unless you're Colin Sega)

}

Type ShapeHeader = record
     ShapeWidth  : Byte;
     ShapeHeight : Byte;
     end;


{ New for 3.2 - it's like ViewPorts in Turbo Pascal, but better :) }

WindowType = record
   WinX          : Word;
   WinY          : Word;
   EndWinX       : Word;
   EndWinY       : Word;
End;




{
=======================================================================

			     PROCEDURES

-----------------------------------------------------------------------
}



Procedure InitVGAMode;
Function  New64KBitmap: Pointer;
Procedure FreeBitmap(Var BmapPtr: Pointer);
Procedure UseBitmap(BmapPtr: Pointer);
Function  GetUsedBitmapAddr: Pointer;


Procedure CopyBitmapTo (DstBmapPtr: Pointer);
Procedure CopyAreaToBitmap ( x1:Word; y1:Byte; x2:Word; y2:Byte;
			     DstBmapPtr: Pointer; DestX:Word; DestY:Byte);
Procedure ShowUsedBitmap;
Procedure CopyBitmap( SrcBMapPtr,  DstBMapPtr : Pointer);
Procedure ShowAllBitmap( TheBMap: Pointer);
Procedure ShowAreaOfBitmap ( TheBMap: Pointer; x1:Word; y1:Byte;
			     x2:Word; y2:Byte; DestX:Word; DestY: Byte);

{ New for 3.5, masked copy }
Procedure CopyMaskedBitmapTo (DstBmapPtr: Pointer);
Procedure CopyMaskedBitmap( SrcBMapPtr,  DstBMapPtr : Pointer);


Procedure FillArea(x1:Word; y1:Byte; x2:Word; y2:Byte; thecolour:Byte);
Procedure Cls;
Procedure CCls(TheColour : Byte);

{ == For version 3.4 == }

Procedure ClrBitmap(TheBMap: Pointer);
Procedure CClrBitmap(TheBMap: Pointer; TheColour: Byte);

{ ===================== }

Procedure Clw;
Procedure CClw(Thecolour : Byte);

Procedure ScrollUp   (X1:Word;Y1:Byte;X2:Word;Y2,pixelstep:Byte);
Procedure ScrollDown (X1:Word;Y1:Byte;X2:Word;Y2,pixelstep:Byte);
Procedure ScrollLeft (X1:Word;Y1:Byte;X2:Word;Y2,pixelstep:Byte);
Procedure ScrollRight(X1:Word;Y1:Byte;X2:Word;Y2,pixelstep:Byte);

Procedure GetWindowSettings(Var TheWindow: WindowType);
Procedure SetWindow(X1,Y1,X2,Y2:Word);
Procedure SetWindowEx(TheWindow: WindowType);
Function  GetMaxX: Word;
Function  GetMaxY: Word;

Procedure PutPixel(X,Y : Integer; ColourValue : Byte);
Function  GetPixel(X,Y : Integer): Integer;
Procedure Line(X1,Y1,X2,Y2 : Integer);
Procedure LineRel(DiffX,DiffY: Integer);
Procedure LineTo(EndX,EndY:Integer);
Procedure Rectangle(X1,Y1,X2,Y2:Integer);

Procedure MoveRel(Dx, Dy: Integer);
Procedure MoveTo(NewCursX,NewCursY:Integer);
Function  GetX: Integer;
Function  GetY: Integer;
Procedure PrintAt(X,Y:Integer; txt:string);
Procedure Print(txt:string);

Procedure GetAShape(X1,Y1,X2,Y2:Word;Var DataPtr);
Procedure FreeShape(DataPtr:Pointer);
Procedure Blit(X,Y:Word; Var DataPtr);
Procedure ClipBlit(X,Y:Integer; Var DataPtr);
Procedure Block(X,Y:Word; Var DataPtr);
Procedure ClipBlock(X,Y:Integer; Var DataPtr);
Function  BlitColl(X,Y :Integer; Var dataptr) : boolean;
Procedure ScaleShape(var DataPtr; X1:Word;Y1:Byte;X2:Word;Y2:Byte);
Procedure ScaleMskShape(var DataPtr; X1:Word;Y1:Byte;X2:Word;Y2:Byte);
Procedure XFlipShape(Var DataPtr);
Procedure YFlipShape(Var DataPtr);
Function  ShapeSize(X1,Y1,X2,Y2:Word):longint;
Function  ExtShapeSize(ShapeWidth, ShapeHeight : Word): longint;
Function  ShapeWidth(Var DataPtr): Word;
Function  ShapeHeight(Var DataPtr): Word;
Procedure LoadShape(FileName:String; Var DataPtr:Pointer);
Procedure SaveShape(FileName:string; DataPtr:Pointer);
Function  ShapeFileHasPalette(FileName:string): boolean;
Procedure LoadShapeWithPalette( FileName: string; Var DataPtr: Pointer;
				Var ThePalette: PaletteType);
Procedure SaveShapeWithPalette( FileName:string; DataPtr:Pointer;
				Var ThePalette: PaletteType;
				First, Second:Byte);

Procedure LoadPCXToBitmap( filename:string; TheBitmap: Pointer;
                           Var ThePalette: PaletteType;
	                   x,y,widthtoshow,heighttoshow:Word);
Procedure LoadPCX(FileName:string; Var ThePalette: PaletteType);
Procedure LocatePCX(filename:string; Var ThePalette: PaletteType;
	  x,y,widthtoshow,heighttoshow:Word);
Procedure SaveBitmapAreaAsPCX(TheBitmap: Pointer;
	  filename:string;ThePalette: PaletteType;
	  x,y, PCXWidth,PCXHeight: Word);
Procedure SaveBitmapAsPCX( TheBitmap: Pointer; filename:string;
			   ThePalette: PaletteType);
Procedure SavePCX(filename:string;ThePalette: PaletteType);
Procedure SaveAreaAsPCX(filename:string;ThePalette: PaletteType;
	  x,y, PCXWidth,PCXHeight: Word);

Function  UseFont(FontNumber:Byte): boolean;
Function  GetFontCharOffset(CharNum:Byte): Word;
Function  GetUsedFontAddr: Pointer;
Procedure SetNewFontAddress(NewFontPtr: Pointer);
Procedure GetCurrentFontSize(Var CurrFontWidth, CurrFontHeight:Byte);
Procedure SetFontSize(NewFontWidth, NewFontHeight:Byte);
Procedure LoadFont(FontFileName:String; Var FontRec: FontType);
Procedure UseLoadedFont(FontRec : FontType);
Procedure SaveFont(FontFileName:String; FirstChar, Numchars:Byte);

Procedure UseColour(NewColour:Byte);
Function  GetColour: Byte;
Procedure GetRGB(ColourNumber : Byte; VAR RedValue, GreenValue,
	  BlueValue : Byte);
Procedure SetRGB(ColourNumber, RedValue, GreenValue, BlueValue : Byte);
Procedure LoadPalette(FileName: String; Var Palette : PaletteType);
Procedure SavePalette(FileName: String; Palette : PaletteType);
Procedure CopyVGAPaletteTo(Var Palette : PaletteType);
Procedure UsePalette(Palette : PaletteType);

Procedure Vwait(TimeOut:Word);
Function  GetVersion: Word;     { Use this to counteract bugs in older
				  versions :) }




IMPLEMENTATION


Uses CRT,DOS,PCXCACH2;  { PCXCACH2.PAS should be in SWAG too }



type Pcxheader_rec=record
     manufacturer:      Byte;
     version:           Byte;
     encoding:          Byte;
     bits_per_pixel:    Byte;
     xmin, ymin:        Word;
     xmax, ymax:        Word;
     hres:              Word;
     vres:              Word;
     palette:           array [0..47] of Byte;
     reserved:          Byte;
     colour_planes:     Byte;
     bytes_per_line:    Word;
     palette_type:      Word;
     filler:            array [0..57] of Byte;
     { So where do the comments go ? }
end;





Const KOJAKVGAVersion  = $305;          { Major = 3, Minor = 5 }
      VGA_MEM_SEG      = $a000;         { New for 3.2 }
      VGA_SCREEN_SIZE  = 64000;         { New }
      SHP_PAL_ATTACHED = $204C4150;     { 'PAL ' }


Var
    ScanLineOffsets:            Array[0..199] of Word;
    CurrentBitmapSegment:       Word;
    CurrentBitmapOffset:        Word;
    CurrentFontSegment:         Word;
    CurrentFontOffset:          Word;
    CurrentFontWidth:           Byte;
    CurrentFontByteWidth:       Byte;
    CurrentFontHeight:          Byte;
    CurrentFontBytesPerChar:    Byte;   { 255 bytes per char max! }

    CurrentColour:              Byte;
    DefaultWindow:              WindowType;
    ViewX:                      Word;   { For 3.2 - You can define }
    ViewY:                      Word;   { your own graphics windows }
    EndViewX:                   Word;   { These vars make clipping faster }
    EndViewY:                   Word;
    ViewWidth:                  Word;
    ViewHeight:                 Word;
    CursorX:                    Integer;
    CursorY:                    Integer;
    header:                     PCXheader_rec;







{
 ==================================================================

			   PROCEDURES

 ------------------------------------------------------------------
}



procedure calculateoffset; near; forward;


{
Switch into VGA256 (320 x 200 x 256 Colour mode).

Expects  : Nothing

Returns  : I am sure that the INT $10 will return a value indicating
	   success on mode change (I can't be bothered checking my
	   interrupt list :) ) but who gives a flying...

Affects  : AX

Notes    : It affects the current screen mode (obviously) palette,
	   Font. But KOJAKVGA still Prints in the font you
	   last used.

	   If all you want to do is clear the screen then use
	   Cls or CCls, which does not affect palettes etc.

}

Procedure InitVGAMode; Assembler;
asm
   XOR AH,AH
   MOV AL,$13    { Mode 19 is what we're after. }
   INT $10
End;









{
****************************

BITMAP MANIPULATION ROUTINES

****************************
}







(*
Allocate memory for a bitmap. (Known as "Virtual Screens" to fellow
anoraks: basically you draw on it, then when all drawing is done,
copy it to VGA RAM to display it so there's no flicker)

As the "64K" part of the function implies, 64K (OK, being pedantic,
64000 bytes) is reserved for the bitmap, and amazingly enough
that's the same size of the Mode 13h bitmap! (OK - I know it's me being
a smart ass, but believe me, typing comments is NOT my idea of fun)


Expects  : Nothing

Returns  : A Pointer to the bitmap allocated.

Affects  : Probably all registers (except DS & SS of course)

*)


Function New64KBitmap: Pointer;
Var MemoryAccessVar: Pointer;
Begin
     GetMem(MemoryAccessVar,VGA_SCREEN_SIZE);
     New64KBitmap:=MemoryAccessVar;
End;









(*
This routine will release the memory occupied by a bitmap back to the
system.

Expects  :  BMapPtr points to an area of memory that was reserved
	    by New64KBitmap ONLY. In other words, if you've not
	    reserved a memory area with New64KBitmap,
	    don't use this command to free it!

Returns  :  Memory used by the bitmap (VGA_SCREEN_SIZE bytes) should be
	    returned to the system heap. Of course, your machine may
	    crash if you try and free a Bitmap that has not been allocated !
	    Doh! :)

Affects  :  Don't know which registers are altered. Yet again, assume
	    ALL registers (except DS & SS)

*)


Procedure FreeBitmap(Var BMapPtr: Pointer);
Begin
     FreeMem(BMapPtr,VGA_SCREEN_SIZE);
     BMapPtr:=Nil;
End;








{
Set the bitmap to use for all drawing/sprite/scrolling routines.
This bitmap is referred to as the "current bitmap". Doh!

Expects  : BMapPtr is a Pointer to the bitmap to use.
	   You can create bitmaps by using the New64KBitmap function,
	   or to draw directly to screen use:

	   UseBitmap(ptr(VGA_ADDR,0));

	   (Or $a000,0 if you can't be bothered with constants)



Returns  : Nothing

Affects  : AX

}




Procedure UseBitmap(BMapPtr : Pointer); Assembler;
Asm
   MOV AX,WORD PTR BMapPtr[0]
   MOV CurrentBitmapOffset,AX
   MOV AX,WORD PTR BMapPtr[2]
   MOV CurrentBitmapSegment,AX
End;







{
Return the address of the bitmap being used for graphics operations.

Expects  : Nothing

Returns  : On exit, GetUsedBitmapAddr = Address of the current bitmap.

Affects  : DX,AX
}


Function GetUsedBitmapAddr: Pointer; Assembler;
Asm
   MOV DX,CurrentBitmapSegment
   MOV AX,CurrentBitmapOffset
End;














{
***************************

BITMAP SCROLL/COPY ROUTINES

***************************
}




{
		     PRIVATE TO UNIT!

			WARNING!

Do NOT expect this routine to be present in any further
KOJAKVGA revisions! (Don't make it public in the
IMPLEMENTATION section)

This routine was only provided to speed up calculation
of an offset for the standard VGA 200 line screen.
}




Procedure InitOffsets; Assembler;
Asm
     XOR AX,AX
     MOV BX,OFFSET ScanLineOffsets
     MOV CL,200

@WriteOffset:
     MOV [BX],AX
     INC BX
     INC BX
     ADD AX,320
     DEC CL
     JNZ @WriteOffset
End;












{
Calculate the address for a pixel on screen.
Private to KOJAKVGA unit.

	  DO NOT ALTER THIS ROUTINE UNLESS YOU KNOW WHAT YOU
	  ARE DOING - MESSING UP REGISTERS ** WILL **
	  CAUSE SOME OF THE GRAPHICS ROUTINES TO FAIL !


Expects:  AX = X coord (0-GetMaxX)
	  BX = Y coord (0-GetMaxY)
	  DS set to point at Turbo's Data Segment

Returns:  If carry flag set then coordinates were invalid. BX
	  will be unchanged.
	  Otherwise, carry is clear (of course)
	  and BX holds screen offset.

Affects:  AX,BX

}



Procedure CalculateOffset; assembler;
Asm
   CMP AX,ViewWidth             { Out of the window ? }
   JAE @InvalidCoord
   CMP BX,ViewHeight
   JAE @InvalidCoord

   ADD AX,ViewX                 { Now calc address for pixel }
   ADD BX,ViewY

   SHL BX,1
   ADD BX,OFFSET ScanLineOffsets
   MOV BX,[BX]
   ADD BX,AX
   ADD BX,CurrentBitmapOffset   { Woohoo! }
   CLC                          { Carry clear indicates success }
   RET                          { Don't f*** about with this :) }

@InvalidCoord:
   STC                          { Faster way of indicating pixel
				  is off screen }
End;







{
Added Friday 15/11/96. On my graduation day! (A few bevvies follow)

This routine does basically the same as CalculateOffset
except that AX and BX specify bitmap coordinates, and NOT relative-
to-window coordinates.

See above for params.

}

Procedure NoWinCalculateOffset; Assembler;
Asm
   CMP AX,319                      { Off bitmap ? }
   JA  @InvalidCoord
   CMP BX,199
   JA  @InvalidCoord

   SHL BX,1
   ADD BX,OFFSET ScanLineOffsets
   MOV BX,[BX]
   ADD BX,AX
   CLC
   RET

@InvalidCoord:
   STC
End;








{
POST INCREMENTAL MOVE
---------------------

You could put this in MEMORY.SWG if you like as it uses 32 bit
instructions to copy data from A to B.

Expects:     DS:SI = Source
	     ES:DI = Dest
	     CX    = Count of bytes

Returns:     Zilch

Affects :    SI,DI, Direction Flag

}



Procedure PostIncMove; Assembler;
Asm
   CLD

   CMP CX,4             { # of bytes to move > 4 ? }
   JB @NoLongs

   PUSH CX
   SHR CX,2             { Divide count by 4 to give number of }
   REPZ                 { long words to move in one go }
   DB $66; MOVSW
   POP CX

@NoLongs:
   TEST CL,3            { Any remaining bytes to move ? }
   JZ @NoBytes
   PUSH CX              { Hope this method's fast }
   AND CL,3             { Can only be 3 bytes max to move }

@WriteLoop:
   MOVSB                { shift em! }
   DEC CL
   JNZ @WriteLoop

   POP CX

@NoBytes:
End;








{
PRE DECREMENTAL MOVE
--------------------

Used for scrolling RIGHT. And this routine was a BAST to write!
It took AGES to debug!


Expects:     DS:SI = Source
	     ES:DI = Dest
	     CX    = Count of bytes

Returns:     Zilch

Affects :    SI,DI, Direction flag


}



Procedure PreIncMove; Assembler;
Asm
   STD

   CMP CX,4                     { Any long words to move ? }
   JB @CouldBeBytes             { No, but there probably is at least 2 }

   PUSH CX                      { As CX is gonna be corrupted, better }
				{ push it on stack eh ? }
   SHR CX,2                     { Get number of long words to move -> CX }

   SUB SI,3                     { A MOVSD overwrites 4 bytes so this }
   SUB DI,3                     { must be taken into account }

@MoveLong:
   REPZ; DB $66; MOVSW

   ADD SI,3                     { Point to previous bytes written -1 }
   ADD DI,3

   POP CX

@CouldBeBytes:
   TEST CL,3
   JZ @NoBytes

   PUSH CX
   AND CL,3

@WriteLoop:
   MOVSB
   DEC CL
   JNZ @writeLoop

   POP CX


@NoBytes:
End;










{
Copy a rectangular area from the Current Bitmap to the bitmap pointed
to by DstBmapPtr. No masking of colour 0 is performed, so the area
will be moved as is, including blank portions.

Expects:  x1,y1,x2,y2 define the rectangular area of the Current Bitmap
	  to be moved.

	  DstBmapPtr is a Pointer to the bitmap where the rectangular
	  area will be copied.


	  ========================================================
	  REVISION FOR 3.2 (SEP 25TH UPDATE):

	  If DstBmapPtr is set Nil then the current bitmap is
	  used (allowing a copy to an area on the same bitmap,
	  but you should be aware that overlapping areas may
	  cause unexpected effects)
	  --------------------------------------------------------


	  DestX and DestY specify where this area will be placed on
	  DstBmapPtr.



Returns:  nothing

Notes:    Updated on September 25th (a day after my 24th birthday,
	  which I spent hung-over !) - Nil Pointer handler
	  implemented.


Affects : AX,BX,CX,DX,SI,DI, ES, Direction flag
}





Procedure CopyAreaToBitmap ( x1:Word;y1:Byte;x2:Word;y2:Byte;
	  DstBmapPtr : Pointer; DestX:Word;DestY:Byte); Assembler;
Asm
     MOV AX,X1
     XOR BH,BH
     MOV BL,Y1
     CALL CalculateOffset
     MOV SI,BX

     MOV AX,DestX
     XOR BH,BH
     MOV BL,DestY
     CALL NoWinCalculateOffset          { Get dest offset in BX }

     PUSH DS

{ This is still compatible with KOJAKVGA 3.1 }


     MOV AX,WORD PTR DstBmapPtr[2]         { Check for Nil Pointer }
     OR AX,AX
     JZ @UseCurrentBMap

     ADD BX,WORD PTR DstBmapPtr[0]
     MOV DI,BX
     MOV ES,WORD PTR DstBmapPtr[2]
     JMP @Resume


@UseCurrentBMap:                        { Only comes here if Nil ptr }
     ADD BX,CurrentBitmapOffset
     MOV DI,BX
     MOV ES,CurrentBitmapSegment


@Resume:
     MOV DS,CurrentBitmapSegment


     MOV CX,X2
     SUB CX,X1
     INC CX             { CX = Number of bytes per line to move }

     MOV DL,Y2
     SUB DL,Y1
     INC DL             { DL = Number of lines to move }

     PUSH BP
     MOV BP,SI          { Oh well that's knackered local var access then :) }
     MOV BX,DI


@Outer:
     MOV AX,320         { Modulo for next scanline on both bitmaps }
     ADD BP,AX          { This will of course change when V3.2 is }
     ADD BX,AX          { released as I will have variable width bmaps }

     CALL PostIncMove

     MOV SI,BP          { point source & dest to next lines }
     MOV DI,BX

     DEC DL
     JNZ @Outer

     POP BP
     POP DS
End;












{
Fill an area of the Current Bitmap with a given colour.
( Version 3.1 & 3.2. had a bug where if the fill width was not exactly
  divisible by 4, unexpected results occurred)

I provided this function so that you could clear an area of your
window clearly (it's especially useful for erasing the "trails" left
by scrolling).

Expects : x1,y1,x2,y2 define a rectangular area on the Current Bitmap
	  to fill with colour <thecolour>

	  i.e. FillArea(0,0,GetMaxX,GetMaxY,255) fills the current
	  window with colour 255.

Returns : Nothing

Affects : AX, BX, CX, DX, SI, DI, ES, Direction Flag
}


Procedure FillArea(x1:Word;y1:Byte;x2:Word;y2:Byte;thecolour:Byte);
Assembler;
Asm
     MOV AX,X1
     XOR BH,BH
     MOV BL,Y1
     CALL CalculateOffset
     MOV DI,BX
     MOV ES,CurrentBitmapSegment

     MOV CX,X2
     SUB CX,X1
     INC CX             { CX = Number of bytes per line to move }

     MOV DL,Y2
     SUB DL,Y1
     INC DL             { DL = Number of lines to move }

     MOV AL,TheColour
     MOV AH,AL
     MOV BX,AX
     DB $66; SHL AX,16  { Fill EAX with AL }
     MOV AX,BX

     MOV SI,BP          { Save BP in SI }
     MOV BP,DI
     CLD

@Outer:
     ADD BP,320         { Point BP to next line }
     MOV BX,CX

     { There was a bug with this in version 3.2: If CX MOD 4
       was not 0, then an error would occur.

       Strange how I never noticed it.. I did test it ya know!
     }

     CMP CX,4
     JB @NoLongs
     SHR CX,2           { Count number of long words in CX }
     REPZ
     DB $66; STOSW

     MOV CL,BL
     AND CL,3
     JZ @NoMoreBytes

@NoLongs:
     STOSB
     DEC CL
     JNZ @NoLongs


@NoMoreBytes:
     MOV CX,BX
     MOV DI,BP          { point source & dest to next lines }

     DEC DL
     JNZ @Outer


     MOV BP,SI
End;









{
Clear the Current Bitmap with Colour 0 (Always).

Expects  : CurrentBitmapSegment, CurrentBitmapOffset to point to the source
	   Bitmap (of course).

Returns  : Nothing.

Affects  : AX,CX,DI,ES, Direction Flag

}


Procedure Cls; Assembler;
Asm
     MOV ES,CurrentBitmapSegment
     MOV DI,CurrentBitmapOffset

     MOV CX,4000         { 4000 x 16 Byte moves are executed }
     DB $66; XOR AX,AX   { XOR EAX,EAX - Colour 0 used to clear screen }
     CLD                 { Forgot this in previous version }

@ClearLoop:
     DB $66; STOSW       { STOSD }
     DB $66; STOSW
     DB $66; STOSW
     DB $66; STOSW
     DEC CX
     JNZ @ClearLoop

End;









{
Clear the screen with the graphics colour specified.

Expects  : CurrentColour set to non-zero value
	   Current Bitmap initialised with Bitmap

Returns  : Nothing

Affects  : AX,BX,CX,DI,ES, Direction Flag
}


Procedure CCls(TheColour : Byte); Assembler;
Asm
   MOV ES,CurrentBitmapSegment
   MOV DI,CurrentBitmapOffset

   MOV CX,4000
   MOV AH,TheColour
   MOV AL,AH
   MOV BX,AX

   DB $66; SHL AX,16            { SHL EAX,16 -> Move AH & AL into
				  upper Word of EAX}
   MOV AX,BX                    { Now EAX is fully set }
   CLD                          { Forgot this in version 3.1 }

@FillLoop:
   DB $66; STOSW                { STOSD }
   DB $66; STOSW
   DB $66; STOSW
   DB $66; STOSW
   DEC CX
   JNZ @FillLoop                { You could use LOOP but I heard this
				  method is faster }
End;






{ For version 3.4:
  Clear the specified bitmap with Colour 0 (Always)

  Expects: TheBMap must point to a valid 64K bitmap.

  Returns: Nothing.

  Affects: EAX,CX,DI,ES
}



Procedure ClrBitmap(TheBMap: Pointer); Assembler;
Asm
     LES DI,TheBMap
     MOV CX,4000         { 4000 x 16 Byte moves are executed }
     DB $66; XOR AX,AX   { XOR EAX,EAX - Colour 0 used to clear screen }
     CLD                 { Forgot this in previous version }

@ClearLoop:
     DB $66; STOSW       { STOSD }
     DB $66; STOSW
     DB $66; STOSW
     DB $66; STOSW
     DEC CX
     JNZ @ClearLoop
End;







{ New for version 3.4:
  Clear the specified bitmap with any colour.

  Expects: TheBMap points to the 64K bitmap to fill with
           colour TheColour.

  Returns: Nothing.

  Affects: EAX, CX, DI, ES
}


Procedure CClrBitmap(TheBMap: Pointer; TheColour: Byte); Assembler;
Asm
   LES DI,TheBMap

   MOV CX,4000
   MOV AH,TheColour
   MOV AL,AH
   MOV BX,AX

   DB $66; SHL AX,16            { SHL EAX,16 -> Move AH & AL into
				  upper Word of EAX}
   MOV AX,BX                    { Now EAX is fully set }
   CLD                          { Forgot this in version 3.1 }

@FillLoop:
   DB $66; STOSW                { STOSD }
   DB $66; STOSW
   DB $66; STOSW
   DB $66; STOSW
   DEC CX
   JNZ @FillLoop                { You could use LOOP but I heard this
				  method is faster }
End;








{
Clear the current window.

Affects: See FillArea command.
}


Procedure Clw;
Begin
     FillArea(0,0,GetMaxX,GetMaxY,0);
End;




{ Duh! Same as above, except you specify the colour to clear the window
  with. }

Procedure CClw(Thecolour : Byte);
Begin
     FillArea(0,0,GetMaxX,GetMaxY,TheColour);
End;






{
Procedure used to blit one bitmap to another bitmap. Private
to unit.

Expects : DS:SI points to source page
	  ES:DI points to destination page
	  DX holds data segment address

Affects  : CX,SI,DI, Direction flag.

Returns : Nothing

}



Procedure FastCopy; Assembler;
Asm
     MOV CX,2000
     CLD

@Copy:
     DB $66; MOVSW      { MOVSD }
     DB $66; MOVSW
     DB $66; MOVSW
     DB $66; MOVSW
     DB $66; MOVSW
     DB $66; MOVSW
     DB $66; MOVSW
     DB $66; MOVSW      { 32 bytes moved in one loop. Whoa !}
     DEC CX
     JNZ @Copy          { On my 486 this is faster than LOOP }

     MOV DS,DX
End;







{
Added Sept 7th 1996.

This routine copies the bitmap currently in use to another bitmap.

Expects:   DstBmapPtr points to the bitmap to copy to.

Returns:   Nothing

Affects :  DX, SI, DI, ES, Direction Flag
}




Procedure CopyBitmapTo(DstBmapPtr: Pointer); Assembler;
Asm
   MOV DX,DS
   MOV ES,WORD PTR DstBmapPtr[2]
   MOV DI,WORD PTR DstBmapPtr[0]
   MOV SI,CurrentBitmapOffset
   MOV DS,CurrentBitmapSegment
   CALL FastCopy
End;







{
With this procedure you can copy basically any bitmap you want
to whereever you want.

Expects  : SrcBmapPtr points to the source (bitmap to copy FROM)
	   If Set to Nil then the current bitmap is used.

	   DstBmapPtr points to the destination (bitmap copying TO)
	   If Set To Nil then the current bitmap is used.

Returns  : Nothing


Affects  : CX, SI, DI, ES, Direction Flag
}



Procedure CopyBitmap( SrcBMapPtr,DstBMapPtr : Pointer);
Assembler;
Asm
   MOV DX,DS
   MOV AX,WORD PTR DstBMapPtr[2]        { Check if Segment is Nil }
   OR  AX,AX
   JNZ @UseDestBMap                     { If not, use that seg as dest }
   MOV DI,CurrentBitmapOffset
   MOV ES,CurrentBitmapSegment
   JMP @NowCheckDest

@UseDestBMap:
   MOV DI,WORD PTR DstBMapPtr           { Get offset }
   MOV ES,AX                            { ES:DI is set }

@NowCheckDest:
   MOV AX,WORD PTR SrcBMapPtr[2]        { Check if Nil Pointer passed in }
   OR AX,AX
   JNZ @UseSrcBMap
   MOV SI,CurrentBitmapOffset           { Yeah, so set up DS & SI }
   MOV DS,CurrentBitmapSegment
   JMP @DoCopy

@UseSrcBMap:
   MOV SI,WORD PTR SrcBMapPtr           { Otherwise use bitmap Pointer }
   MOV DS,AX

@DoCopy:
   CALL FastCopy
End;







{
Added 12:08:96 - for KOJAKVGA 3.1 (It was posted to the SWAG
but (ahem) it's kinda buggy & shocky etc. etc. Gayle
DEFINITELY wouldn't want to publish it ;)

Oh no! It has been published! And when I refer to the text it says
"KojakVGA 3.1 is the business" - what an embarassment.


This routine displays the bitmap currently in use.

Expects : Nothing, although the current bitmap should be a system
	  friendly area of memory.

Returns : Nothing

Affects : AX, DX, SI, DI, ES, Direction Flag
}



Procedure ShowUsedBitmap; Assembler;
Asm
   MOV AX,VGA_MEM_SEG
   MOV ES,AX
   MOV DI,0
   MOV SI,CurrentBitmapOffset
   MOV DX,DS
   MOV DS,CurrentBitmapSegment
   CALL FastCopy
End;








{
Display a bitmap on screen immediately.


Expects  : TheBMap points to the bitmap to display on screen.
	   If Set to Nil then the current bitmap is used.

Returns  : Nothing

Affects  : AX,CX,DX,SI,DI,ES
}


Procedure ShowAllBitmap(TheBmap:Pointer); Assembler;
Asm
   MOV DX,DS
   MOV AX,VGA_MEM_SEG
   MOV ES,AX
   XOR DI,DI

   MOV AX,WORD PTR TheBMap[2]
   OR AX,AX                             { Nil Pointer ? }
   JZ @UseCurrent                       { Yes, so display current bitmap }
   MOV SI,WORD PTR TheBMap              { Otherwise, display bitmap }
   MOV DS,AX                            { pointed to by TheBmap }
   CALL FastCopy
   JMP @EndNow

@UseCurrent:
   MOV SI,CurrentBitmapOffset
   MOV DS,CurrentBitmapSegment
   CALL FastCopy

@EndNow:
End;









{
This command shows a portion (or all) of the specified bitmap
immediately on screen.


Expects : TheBMap is a Pointer to the bitmap to use.
	  If set Nil then the current bitmap is used.

	  x1,y1,x2,y2 define the rectangular window to be shown.
	  (i.e. values 0,0,319,199 means the entire bitmap)
	  DestX, DestY define where the rectangular area shall be
	  placed ** in the current window **

	  e.g.
	  ShowAreaOfBitmap(MyBMap, 0,0,319,199,0,0) would place the entire
	  bitmap which resides at MyBMap on the top left of your
	  graphics window.

Returns : Nothing


Affects : AX,BX,CX,DX,SI,DI,ES, direction flag.
}



Procedure ShowAreaOfBitmap( TheBMap: Pointer; x1:Word; y1:Byte;
			    x2:Word; y2:Byte; DestX:Word; DestY: Byte);
Assembler;
Asm
     MOV AX,X1
     XOR BH,BH
     MOV BL,Y1
     CALL NoWinCalculateOffset  { NoWinCalculateOffset does not
				  take into account the current
				  GFX window }
     JC @StupidUser
     MOV SI,BX                  { DS:SI = Area copying FROM }

     MOV AX,DestX
     XOR BH,BH
     MOV BL,DestY
     CALL CalculateOffset
     JC @StupidUser
     MOV DI,BX                  { ES:DI = Area copying TO }

     PUSH DS
     MOV AX,VGA_MEM_SEG
     MOV ES,AX


{ Check if Nil Pointer passed in }

     MOV AX,WORD PTR TheBMap[2]
     OR AX,AX
     JNZ @UseOtherBMap

     ADD SI,CurrentBitmapOffset
     MOV DS,CurrentBitmapSegment
     JMP @ContinueCalcs

@UseOtherBMap:
     ADD SI,WORD PTR TheBMap
     MOV DS,AX

@ContinueCalcs:
     MOV CX,X2
     SUB CX,X1
     INC CX                     { CX = Number of bytes per line to move }

     MOV DL,Y2
     SUB DL,Y1
     INC DL                     { DL = Number of lines to move }

     PUSH BP
     MOV BP,SI                  { BP is faster than using el pusho }
     MOV BX,DI


@Outer:
     MOV AX,320                 { Bump to next line on bitmaps }
     ADD BP,AX                  { BP = Current Bitmap }
     ADD BX,AX                  { BX = VGA Screen }
     CALL PostIncMove
     MOV SI,BP                  { point source & dest to next lines }
     MOV DI,BX

     DEC DL
     JNZ @Outer

     POP BP                     { A POP is faster than using the MSW of }
     POP DS                     { a 32 bit data register. Strange! :)   }

@StupidUser:
End;





{
================================================

MASKED BITMAP COPY ROUTINES NEW FOR VERSION 3.5

------------------------------------------------
}


{
Procedure used to blit one bitmap to another bitmap. Private
to unit.

Expects : DS:SI points to source page
	  ES:DI points to destination page
	  DX holds data segment address

Affects  : CX,SI,DI, Direction flag.

Returns : Nothing
}



Procedure MaskedCopy; assembler;
asm
   MOV CX,VGA_SCREEN_SIZE { 320 x 200 }

@MainLoop:
   MOV AL,[SI]
   OR AL,AL             { Do we have a 0 byte ? }
   JZ @NoCopyByte       { If so, don't copy it }
   MOV [ES:DI],AL       { Otherwise, store it }

@NoCopyByte:
   INC SI               { Read next byte from src bitmap }
   INC DI               { Point to next byte on dst bitmap }
   DEC CX
   JNZ @MainLoop

   MOV DS,DX
end;





{ This does the same as CopyBitmapTo, except that colour 0 is not copied
  to the bitmap specified by DstBmapPtr.

  Expects : DstBmapPtr is the bitmap to copy the current bitmap TO.

  Returns : Nothing.

  Corrupts: AL, CX, DX, SI, DI, ES.
}

Procedure CopyMaskedBitmapTo (DstBMapPtr: Pointer); Assembler;
asm
   MOV DX,DS
   MOV ES,WORD PTR DstBmapPtr[2]
   MOV DI,WORD PTR DstBmapPtr[0]
   MOV SI,CurrentBitmapOffset
   MOV DS,CurrentBitmapSegment
   CALL MaskedCopy
end;




Procedure CopyMaskedBitmap( SrcBMapPtr,DstBMapPtr : Pointer); assembler;
Asm
   MOV DX,DS
   MOV AX,WORD PTR DstBMapPtr[2]        { Check if Segment is Nil }
   OR  AX,AX
   JNZ @UseDestBMap                     { If not, use that seg as dest }
   MOV DI,CurrentBitmapOffset
   MOV ES,CurrentBitmapSegment
   JMP @NowCheckDest

@UseDestBMap:
   MOV DI,WORD PTR DstBMapPtr           { Get offset }
   MOV ES,AX                            { ES:DI is set }

@NowCheckDest:
   MOV AX,WORD PTR SrcBMapPtr[2]        { Check if Nil Pointer passed in }
   OR AX,AX
   JNZ @UseSrcBMap
   MOV SI,CurrentBitmapOffset           { Yeah, so set up DS & SI }
   MOV DS,CurrentBitmapSegment
   JMP @DoCopy

@UseSrcBMap:
   MOV SI,WORD PTR SrcBMapPtr           { Otherwise use bitmap Pointer }
   MOV DS,AX

@DoCopy:
   CALL MaskedCopy
End;




Procedure ShowUsedMaskedBitmap; Assembler;
Asm
   MOV AX,VGA_MEM_SEG
   MOV ES,AX
   MOV DI,0
   MOV SI,CurrentBitmapOffset
   MOV DX,DS
   MOV DS,CurrentBitmapSegment
   CALL FastCopy
End;




{
==================================================================
			 SCROLL ROUTINES
------------------------------------------------------------------
}





{
Scroll a rectangular region of the Current Bitmap UP

Expects:  x1,y1,x2,y2 define the rectangular area.
	  pixelstep is the number of pixels UP you wish to scroll.

Returns:  Nothing

Affects : AX,BX,CX,DX,SI,DI,ES,Direction flag
}



Procedure ScrollUp(x1:Word;y1:Byte;x2:Word;y2,pixelstep:Byte); Assembler;
Asm
     MOV AX,X1
     XOR BH,BH
     MOV BL,Y1
     MOV DX,BX               { Instead of pushing BX on stack }
     CALL CalculateOffset
     MOV SI,BX

     MOV BX,DX
     XOR CH,CH
     MOV CL,pixelstep
     SUB BX,CX
     CALL CalculateOffset    { Calculate address for X1,(Y1 - pixelstep) }
     MOV DI,BX

     PUSH DS

     MOV AX,CurrentBitmapSegment
     MOV DS,AX
     MOV ES,AX

     MOV CX,X2
     SUB CX,X1
     INC CX             { CX = Number of bytes per line to move }

     MOV DL,Y2
     SUB DL,Y1
     INC DL             { DL = Number of lines to move }

     PUSH BP
     MOV BP,SI          { Oh well that's knackered local var access then :) }
     MOV BX,DI


@Outer:
     MOV AX,320
     ADD BP,AX
     ADD BX,AX

     CALL PostIncMove

     MOV SI,BP          { point source & dest to next lines }
     MOV DI,BX

     DEC DL
     JNZ @Outer

     POP BP             { Restore the 2 essential registers }
     POP DS
End;







{
Scroll a rectangular region of the Current Bitmap DOWN

Notice how most of the code is similar to scrollup. Well if this was
C/C++ I could've made the code body an inline procedure and then the
source file would've been v. small. But, Pascal being what it is..

So Borland, how's about upgrading ye olde Pascal?

And I'm not talking Delphi, I want DOS stuff - fastest, see? :)


Expects:  x1,y1,x2,y2 define the rectangular area.
	  pixelstep is the number of pixels down you wish to scroll.

Returns:  Nothing

Affects : AX,BX,CX,DX,SI,DI,ES, Direction flag
}



Procedure ScrollDown(x1:Word;y1:Byte;x2:Word;y2,pixelstep:Byte); Assembler;
Asm
     MOV AX,X1
     XOR BH,BH
     MOV BL,Y2
     MOV DX,BX                { Instead of pushing BX on stack }
     CALL CalculateOffset
     MOV SI,BX

     MOV BX,DX
     XOR CH,CH
     MOV CL,pixelstep
     ADD BX,CX
     CALL CalculateOffset     { Calculate address for X1,(Y1 + pixelstep) }
     MOV DI,BX

     PUSH DS

     MOV AX,CurrentBitmapSegment
     MOV DS,AX
     MOV ES,AX

     MOV CX,X2
     SUB CX,X1
     INC CX             { CX = Number of bytes per line to move }

     MOV DL,Y2
     SUB DL,Y1
     INC DL             { DL = Number of lines to move }


     PUSH BP
     MOV BP,SI          { Oh well that's knackered local var access then :) }
     MOV BX,DI          { ^ Do you get this deja vu feeling I've said that
			  before? :) }


@Outer:
     MOV AX,320
     SUB BP,AX
     SUB BX,AX

     CALL PostIncMove

     MOV SI,BP          { point source & dest to next lines }
     MOV DI,BX

     DEC DL
     JNZ @Outer

     POP BP             { Restore the 2 essential registers }
     POP DS
End;








{
Scroll a rectangular region of the Current Bitmap LEFT.

Expects:  x1,y1,x2,y2 define the rectangular area.
	  pixelstep is the number of pixels left you wish to scroll.

Returns:  Nothing

Affects : AX,BX,CX,DX,SI,DI,ES, Direction flag
}



Procedure ScrollLeft(x1:Word;y1:Byte;x2:Word;y2,pixelstep:Byte); Assembler;
Asm
     MOV AX,X1
     XOR BH,BH
     MOV BL,Y1
     MOV DX,BX                { Instead of pushing BX on stack }
     CALL CalculateOffset
     MOV SI,BX

     MOV BX,DX
     XOR CH,CH
     MOV CL,pixelstep
     SUB AX,CX
     CALL CalculateOffset    { Calculate address for (X1-pixelstep),Y1 }
     MOV DI,BX

     PUSH DS
     MOV AX,CurrentBitmapSegment
     MOV DS,AX
     MOV ES,AX

     MOV CX,X2
     SUB CX,X1
     INC CX                  { CX = Number of bytes per line to move }

     MOV DL,Y2
     SUB DL,Y1
     INC DL                  { DL = Number of lines to move }

     PUSH BP
     MOV BP,SI               { Oh well that's knackered local var
			       access then (spot the block copying) :) }
     MOV BX,DI


@Outer:
     MOV AX,320              { Bytes per scan line }

     ADD BP,AX
     ADD BX,AX

     CALL PostIncMove

     MOV SI,BP               { point source & dest to next lines }
     MOV DI,BX

     DEC DL
     JNZ @Outer

     POP BP                  { Restore the 2 essential registers }
     POP DS
End;







{
Scroll a rectangular region of the Current Bitmap RIGHT

Expects:  x1,y1,x2,y2 define the rectangular area.
	  pixelstep is the number of pixels right you wish to scroll.

Returns:  Nothing

Affects : AX,BX,CX,DX,SI,DI,ES, Direction flag

Notes:    The PreInc routine was a bloody nightmare to write so it
	  had better be appreciated :)
}



Procedure ScrollRight(x1:Word;y1:Byte;x2:Word;y2,pixelstep:Byte); Assembler;
Asm
     MOV AX,X2
     XOR BH,BH
     MOV BL,Y1
     MOV DX,BX                { Instead of pushing BX on stack }
     CALL CalculateOffset
     MOV SI,BX

     MOV BX,DX
     XOR CH,CH
     MOV CL,pixelstep
     ADD AX,CX
     CALL CalculateOffset    { Calculate address for (X1-pixelstep),Y1 }
     MOV DI,BX

     PUSH DS

     MOV AX,CurrentBitmapSegment
     MOV DS,AX
     MOV ES,AX

     MOV CX,X2
     SUB CX,X1
     INC CX             { CX = Number of bytes per line to move }

     MOV DL,Y2
     SUB DL,Y1
     INC DL             { DL = Number of lines to move }


     PUSH BP
     MOV BP,SI          { Oh well that's knackered local var access then :) }
     MOV BX,DI

@Outer:
     MOV AX,320
     ADD BP,AX
     ADD BX,AX

     CALL PreIncMove

     MOV SI,BP
     MOV DI,BX
     DEC DL
     JNZ @Outer

     POP BP
     POP DS
End;













{
Added Nov 2nd 1996 for KOJAKVGA 3.2

Get the current window settings. For example, full screen
will return in structure TheWindow:

    WinX       : 0
    WinY       : 0
    EndWinX    : 319
    EndWinY    : 199

Expects: TheWindow is used to hold the current Window settings.

Returns: TheWindow should contain current window settings.

Affects: Unknown
}

Procedure GetWindowSettings(Var TheWindow: WindowType);
Begin
   With TheWindow Do
   Begin
        WinX := ViewX;
        WinY := ViewY;
        EndWinX:= EndViewX;
        EndWinY:= EndViewY;
   End;


End;






{ For KojakVGA 3.5.1

Set window dimensions using WindowType structure.

Expects: TheWindow holds the dimensions of the window to set.

Returns: Nothing

Affects: AX, DI, ES
}

Procedure SetWindowEx(TheWindow: WindowType);
Begin
   With TheWindow Do
   Begin
        ViewX:=WinX;
        ViewY := WinY;
        EndViewX:= EndWinX;
        EndViewY:= EndWinY;
   End;

End;













{
Define the window where ** ALL ** graphics operations will be
performed.

Expects : X1,Y1,X2,Y2 defines the graphics window.

Returns : Nothing

Affects : AX, BX.

Notes   : All individual pixel based routines (any routine that
	  calls FPutPixel, to be more precise) will clip to the
	  defined window.


	  WARNING:

	  For speed, the standard Blit/Block routines
	  and Scrollxxxxx do NOT clip, so you will have to
	  be careful if you wish to preserve data outside the
	  current window.

	  Luckily you can clip shapes (using ClipBlit) and as
	  for scrolling you just need to specify the
	  X1,Y1,X2,Y2 variables to suit the current
	  window settings.

	  e.g.
	      ScrollLeft(1,1,GetMaxX,GetMaxY,1);

}

Procedure SetWindow(X1,Y1,X2,Y2: Word); Assembler;
Asm
   MOV AX,X1
   MOV ViewX,AX
   MOV BX,X2
   MOV EndViewX,BX
   SUB BX,AX
   INC BX
   MOV ViewWidth,BX
   MOV AX,Y1
   MOV ViewY,AX
   MOV BX,Y2
   MOV EndViewY,BX
   SUB BX,AX
   INC BX
   MOV ViewHeight,BX
End;










{
Change position of graphics cursor.

Expects  : NewCursX and NewCursY are the horizontal and vertical
	   coordinates that you wish to move the cursor to.
	   NewCursX may be negative or more than GetMaxX.
	   NewCursY may be negative or more than GetMaxY.

Returns  : Nothing

Affects  : AX.
}


Procedure MoveTo(NewCursX,NewCursY:Integer); Assembler;
Asm
   MOV AX,NewCursX
   MOV CursorX,AX
   MOV AX,NewCursY
   MOV CursorY,AX
End;







{
Change graphics cursor position relative to current position.

Expects  : Dx and Dy are values which determine coordinates relative
           to the current cursor position.
           Dx and Dy may be negative.

Returns  : Nothing
}




Procedure MoveRel(Dx, Dy: Integer); Assembler;
Asm
   MOV AX,Dx
   ADD CursorX,AX
   MOV AX,Dy
   ADD CursorY,AX
End;










{
Returns horizontal position of graphics cursor.
GetX May be negative.

Expects : Nothing

Returns : GetX = Current graphics cursor horizontal position, which
	  may be negative or even exceed GetMaxX.

Affects : AX

Notes   : This is a prime candidate for an inline procedure! :)
}


Function GetX: Integer; Assembler;
Asm
   MOV AX,CursorX
End;








{
Returns vertical position of graphics cursor.
GetY may be negative.

Expects : Nothing

Returns : GetY = Current graphics cursor vertical position, which
	  may be negative or even exceed GetMaxY.

Affects : AX

Notes   : Yet another suitable candidate for an inline procedure
	  or macro!!!
}

Function GetY: Integer; Assembler;
Asm
     MOV AX, CursorY
End;









{ If I documented these one-liners, I'd be a sucker ;)
  Changed from consts to functions on Nov 6th 1996.
}


Function GetMaxX: Word; Assembler;
asm
   MOV AX,ViewWidth     { Width is in bytes.. }
   DEC AX               { And we need it starting from 0.. }
end;




{
Some of you may wonder how I manage to stay awake whilst writing
rather boring routines like GetMaxY. Well, dance music (esp.
house stuff from 1989-90) helps me, as does large quantities
of lager. (Well, everyone needs a bad habit to stop AnorakDom
from setting in!)
}

Function GetMaxY: Word; Assembler;
asm
   MOV AX,ViewHeight
   DEC AX
end;








{
Get the colour value of a pixel at X,Y on the current bitmap.

Expects  : X and Y specify the horizontal and vertical coordinates of
	   a pixel. X may be 0..GetMaxX, Y may be 0..GetMaxY.

Returns  : If the coordinates are within screen bounds, then GetPixel =
	   Colour at X,Y. If not, then GetPixel = -1.

Affects  : AX/BX/CX/DX/FS.
}

Function GetPixel(X,Y: Integer): Integer; Assembler;
Asm
   MOV AX,X
   MOV BX,Y

   CALL CalculateOffset         { Now get offset in BX }
   JC @NoGet                    { Yes, so return value of -1 }

   DB $8E, $26
   DW OFFSET CurrentBitmapSegment

   XOR AH,AH
   DB $64
   MOV AL,[BX]

   JMP @Finished                { Can't put a RET here - maybe this
				  unit was compiled in FAR mode, and
				  a crash would occur! }

@NoGet:
   MOV AX,-1                    { AX = -1, meaning no pixel could be
				  read }

@Finished:
End;






{
Write a pixel to the screen.

Expects  :  AX to be the X coord for a pixel (0 to GetMaxX),
	    BX for the Y coord (0 to GetMaxY) - Don't be tempted
	    to optimize the code by using BL, as this causes
	    problems when using negative Y coordinates. (As some
	    programs will)
	    DL is the colour (0 to 255) to plot.

Returns  :  Nothing

Affects  :  AX,BX,CX,DL,FS

Notes    :  This putpixel is private to the unit and should be
	    used when plotting pixels that MAY be off screen
	    to keep in step with the rest of the unit.

}



Procedure FPutPixel; Near; Assembler;
Asm
   CALL CalculateOffset                 { AX/ BX already set up }
   JC @NoPlot                           { If off screen don't put pixel }

   DB $8E,$26                           { MOV FS, [CurrentBitmapSegment] }
   DW OFFSET CurrentBitmapSegment
   DB $64                               { MOV [FS:BX],DL }
   MOV [BX],DL

@NoPlot:
End;








{
If Turbo Pascal supported 'Macros' or inline procedures (NOT COMPOSED
OF 99000 HEXADECIMAL CODES) then this would have been perfect.


Expects  : X = Horizontal coordinate of a pixel (0-GetMaxX)
	   Y = Vertical coordinate of a pixel (0-GetMaxY)
	   ColourValue = Colour to plot , 0 - 255.

Returns  : Nothing

Affects  : See FPutPixel.
}

Procedure PutPixel(x, y : Integer; ColourValue : Byte); Assembler;
Asm
   MOV AX,x               { Wish pascal allowed Macros! }
   MOV BX,y
   MOV DL,ColourValue
   CALL FPutPixel         { Don't use a JMP, your program will crash }
End;









{
A graphics primitive: draw a line from A to B in currentcolour.

Expects : X1,Y1 defines the horizontal, vertical start (A) of the line
	  X2,Y2 defines the horizontal, vertical end (B) of the line.
	  Coordinates may be negative or exceed screen bounds.
	  Line will be drawn in CurrentColour, and will be clipped
	  as necessary.


Returns : Nothing

Affects : AX,BX,CX,DX,SI,DI,ES,FS.

Notes   : Sean Palmer's line draw routine IS fast (faster than this!)
	  but there is absolutely NO LINE CLIPPING in Sean's
	  procedure so drawing off the screen edges causes (ahem)
	  problems. And no, I couldn't be bothered adding my own
	  clipping algorithms to his code either.
}


Procedure Line(X1, Y1, X2, Y2: Integer); Assembler;
Var
  LgDelta,
  ShDelta,
  LgStep,
  ShStep,
  Cycle : Word;

Asm
  MOV BX,X2               { LgDelta = X2 - X1 }
  MOV SI,X1
  SUB BX,SI
  MOV LgDelta,BX

  MOV CX,Y2               { ShDelta = Y2 - Y1 }
  MOV DI,Y1
  SUB CX,DI
  MOV ShDelta,CX

  TEST BH,$80             { If bit 7 not set .. }
  JZ @LgDeltaPos          { Goto LgDeltaPos }

  NEG BX
  MOV LgDelta,BX
  MOV LgStep,-1
  JMP @Cont1

@LgDeltaPos:
  MOV LgStep,1

@Cont1:
  CMP CH,$80             { If ShDelta < 0 Then.. }
  JB @ShDeltaPos
  NEG CX
  MOV ShDelta,CX
  MOV ShStep,-1          { Means move up }
  JMP @Cont2

@ShDeltaPos:
  MOV ShStep,1           { Means move down }

@Cont2:
  CMP BX,CX              { BX = LgDelta, CX = ShDelta }
  JB @OtherWay

  SHR BX,1               { Cycle:= LgDelta SHR 1 }
  MOV Cycle,BX

  MOV CX,X2


{
Best to leave AX free actually as it's the fastest register to work with
}



@FirstLoop:
  CMP SI,CX              { While X1 <> X2 }
  JZ @GetTheShitOut      { When end of line reached }

  MOV AX,SI              { Set AX and BX to X1,Y1 ready for call }
  MOV BX,DI              { BX = Y1 }

  MOV DL,CurrentColour
  CALL FPutPixel

  ADD SI,LgStep          { X1 = X1 + LgStep }
  MOV AX,ShDelta
  ADD Cycle,AX           { Inc(Cycle,ShDelta) }
			 { If you recall the last time I said "This is
			   fastest" - I was wrong! }
  MOV BX,LgDelta
  CMP AX,BX              { If Cycle > LgDelta }
  JB @FirstLoop

  ADD DI,ShStep          { Y1 = Y1 + ShStep }
  SUB Cycle,BX           { Dec(Cycle,LgDelta) }
  JMP @FirstLoop

{
O.K. If we go in a different direction..
On entry, BX = LgDelta, CX = ShDelta
}

@OtherWay:
  MOV AX,CX
  SHR AX,1              { ShDelta SHR 1 }
  MOV Cycle,AX
  XCHG BX,CX            { BX = ShDelta, CX = LgDelta }
  MOV LgDelta, BX
  MOV ShDelta, CX

  MOV AX,LgStep         { Swap LgStep and ShStep round }
  MOV BX,ShStep
  MOV ShStep,AX
  MOV LgStep,BX

  MOV CX,Y2



@SecondLoop:
  CMP DI,CX             { While Y1 <> Y2 do }
  JZ @GetTheShitOut


{
If it can, then it's time for action!
}

  MOV AX,SI             { Set AX and BX to X1,Y1 }
  MOV BX,DI             { BX = Y1 }

  MOV DL,CurrentColour
  CALL FPutPixel

  ADD DI,LgStep         { Inc(Y1,LgStep) }
  MOV AX,ShDelta        { Inc(Cycle,ShDelta) }
  ADD Cycle,AX

  MOV BX,LgDelta

  CMP AX,BX             { If Cycle > LgDelta Then.. }
  JB @SecondLoop

  ADD SI,ShStep         { Inc(X1,ShStep) }
  SUB Cycle,BX          { Dec(Cycle,LgDelta) }
  JMP @SecondLoop


@GetTheShitOut:
  MOV AX,X2             { Write last pixel. This was an absolute }
  MOV BX,Y2             { b****** to debug :-) }
  MOV DL,CurrentColour
  CALL FPutPixel        { Just a wee bit of Scottish humour there }

End;
















{
Draw a line relative from the current cursor position.

Relative means that the DiffX and DiffY values are added to the
current cursor coordinates to give the resulting horizontal and vertical
end points of the line.

For example, if CursorX and CursorY were 10,10 and DiffX and DiffY
were -10,-10 then the line would be drawn to position 0,0. Conversely,
if DiffX was 10 and DiffY was 20 then the cursor would be drawn to
X 20, Y 30.


Expects  : DiffX is a non zero value that may be negative, which
	   specifies the relative distance from the current horizontal
	   cursor position.

	   DiffY specifies the relative distance from the current
	   vertical position.

Returns  : Nothing

Affects  : Probably the same as the Line routine.
}

Procedure LineRel(DiffX,DiffY: Integer); Assembler;
Asm
     MOV  AX,CursorX    { Calculate X + DiffX }
     MOV  BX,AX
     ADD  AX,DiffX
     PUSH AX

     MOV  AX,CursorY    { Y + Diffy }
     MOV  CX,AX
     ADD  AX,DiffY
     PUSH AX

     PUSH BX            { X }
     PUSH CX            { Y }
     CALL Line          { Can't use JMP, we must return to clear stack }
End;








{
Draw from the current cursor position to the horizontal and vertical
positions specified by EndX and EndY. The Graphics Cursor will be
moved to EndX, EndY.

Expects : EndX to be the horizontal position of the line end. (0 to GetMaxX)
	  EndY to be the vertical position of the line end. (0 to GetMaxY)

Returns : Nothing, but you should be aware that the graphics cursor
	  position is now at EndX, EndY.

Affects : AX,BX,CX,DX,SI,DI,ES,FS

}


Procedure LineTo(EndX,EndY:Integer); Assembler;
Asm
   PUSH EndX
   PUSH EndY
   PUSH CursorX
   PUSH CursorY
   CALL Line
   MOV AX,EndX
   MOV CursorX,AX
   MOV AX,EndY
   MOV CursorY,AX
End;







{
I STILL couldn't be bothered optimizing this, as, lets face it
it's fast enough already (for my uses) and typing in 20 PUSH
instructions is not my idea of breaking programming boundaries :)


Expects  : X1,Y1,X2,Y2 define the rectangular area.

Returns  : Nothing

Affects  : See Line Routine.

Notes    : This routine does not move the graphics cursor.
}


Procedure Rectangle(x1,y1,x2,y2:Integer);
Begin
     Line(x1,y1,x2,y1);         { Top Line    }
     Line(x1,y2,x2,y2);         { Bottom Line }
     Line(x1,y1+1,x1,y2-1);     { Left edge   }
     Line(x2,y1+1,x2,y2-1);     { Right edge  }
End;














{
====================================================================


			 SPRITE FUNCTIONS


--------------------------------------------------------------------
}







{
Get the width of a shape
(Return value size has been changed to accommodate a larger sprite
 size which shall appear sometime in 1997)

Expects  : DataPtr^ points to a shape in memory

Returns  : Width of shape (1-32767)

Affects  : AX, DI, ES
}

Function ShapeWidth(Var DataPtr): Word; assembler;
Asm
   LES DI,DataPtr
   XOR AH,AH
   MOV AL,[ES:DI]
End;








{
Get the height (in pixels) of a shape.

Expects  : DataPtr^ points to a shape held in memory

Returns  : Height of shape (1-65535)

Affects  : AX, DI, ES
}

Function ShapeHeight(Var DataPtr): Word; assembler;
Asm
   LES DI,DataPtr
   XOR AH,AH
   MOV AL,[ES:DI+1]
End;







{
This Function returns the number of bytes required to store
a shape object of a given width and height.

Expects  : ShapeWidth is the width of the Shape (1-32767). You can
	   obtain the width of a shape by using the ShapeWidth
	   Function above.

	   Shapeheight is the height of the Shape (1-65535). You can
	   obtain the height of a shape by using the ShapeHeight
	   Function above.

Returns  : ExtShapeSize = No of bytes shape uses.


Affects  : AX,BX,DX.

}


Function ExtShapeSize(ShapeWidth, ShapeHeight : Word): longint; Assembler;
Asm
   MOV AX, ShapeWidth
   MOV BX, ShapeHeight
   MUL BX
   ADD AX,TYPE ShapeMemFmt
   ADC DL,0
End;









{
Calculate the number of bytes required to hold a shape object in memory.


Expects :     X1, Y1, X2, and Y2 define a rectangular region that
	      defines the area of the shape.

	      X1 and X2 must be in the range of 0-319;
              Y1 and Y2 must be in the range of 0-199.

	      You are currently restricted to images up to
              255 x 200 pixels in size. (Why 200? Well, you can't
              grab past the vertical limits of the VGA screen can you ?)

	      Next version of KOJAKVGA allows the user to grab sprites
	      of any size.. And yes, I WILL write a sprite conversion
	      utility so that you don't need to re-grab images for the
	      new shape format required.



Returns :     Number of bytes used to hold image. If 0, then this
	      means the image is too large to load into a 64K
	      portion of RAM.

Affects  :    AX,BX,CL,DX.
}


Function ShapeSize(x1,y1,x2,y2:Word):longint; Assembler;
Asm
     MOV AX,x2          { Width = (X2 - X1) + 1 }
     SUB AX,x1
     INC AX             { Add one extra width Byte }

@NoWidthCheck:
     MOV BX,y2          { Height = (Y2 - Y1) + 1 }
     SUB BX,y1
     INC BX             { Add in one extra Byte }
     OR BH,BH           { If width >255 then an error }
     JZ @ShapeFine      { If not, sprite size is OK }

@TooBig:
     XOR AX,AX          { Set AX to return 0, meaning error }
     JMP @Finished

@ShapeFine:
     MUL BX                   { SpriteDataSize = Width * Height }
     ADD AX,TYPE ShapeMemFmt  { Take sprite header size into account }
     ADC DL,0                 { Just in case there's a carry }

@Finished:
End;











{
Display a shape at a given position on the Current Bitmap,
over the current background (Most games with sprites use this
technique). Hopefully this'll be the fastest sprite routine in the
SWAG.

Expects  : X and Y specify a horizontal and vertical position for
	   the TOP LEFT of a shape. (Regardless whether or not the
	   shape's edge is transparent)

	   X and Y are presumed ALWAYS valid : i.e. Within bounds of
	   Current Bitmap; Also, it is presumed that the sprite is not
	   placed in a position on screen that over runs the screen
	   borders: unexpected effects would occur. Sorry! Use
	   ClipBlit if you must place sprites in the border.

	   DataPtr, the untyped variable, must point to data for a
	   sprite which is up to 255 pixels wide and 200 pixels
	   tall.

Returns  : Nothing

Affects  : AX,BX,CX,DX,SI,DI,ES, & Direction Flag
}


Procedure Blit(x,y:Word; Var DataPtr); Assembler;
Asm
   MOV AX,x
   MOV BX,y
   CALL CalculateOffset         { Calculate where to blit to }
   JC @StupidUser

   MOV ES,CurrentBitmapSegment  { Point ES to Current Bitmap }
   MOV CX,DS                    { Faster than stack }
   LDS SI,DataPtr               { Point DS:SI to sprite data }
   MOV DX,[SI]                  { Get Width into DL and height to DH }
   INC SI                       { Faster than ADD SI,2 - I think }
   INC SI
   CLD                          { Make sure writes are descending }

   MOV AH,DL                    { Save width in CL }

@Outer:
   MOV DL,AH                    { Reload DL }
   MOV DI,BX                    { DI = Where to write to }


@Main:
   LODSB                { Read Byte from DS:SI }
   OR AL,AL             { Is it value 0, meaning transparent ? }
   JZ @NoBlit           { Yes, so ignore Byte }
   MOV [ES:DI],AL       { Otherwise write it to the screen. Don't
			  use STOSB ! }

@NoBlit:
   INC DI
   DEC DL               { Reduce horizontal counter }
   JNZ @Main            { If not zero then do next Byte of the
			  sprite column }

@NextScanLine:
   ADD BX,320           { Move down 1 scan line }
   DEC DH               { Reduce vertical count }
   JNZ @Outer           { If not all lines of sprite done back to @Outer }
   MOV DS,CX            { Restore Data Segment }

@StupidUser:

End;











{
This routine writes a shape to the Current Bitmap with no Colour 0
transparency, totally overwriting everything "beneath" it.
Also, there is no clipping of Shape. (Use ClipBlock for this
purpose)

Expects  : X and Y specify the horizontal and vertical coordinate
	   of the Shape pointed to by DataPtr.

Returns  : Nothing

Affects  : AX,BX,CL,DX,SI,DI,ES

Notes    : Block is especially useful for "tile" based maps.
}


Procedure Block(x,y:Word; Var DataPtr); Assembler;
Asm
   MOV AX,x
   MOV BX,y
   CALL CalculateOffset
   JC @StupidUser

   MOV DX,DS                    { Save DS with DX }
   MOV ES,CurrentBitmapSegment   { ES: BX -> Where sprite written to }

   CLD                          { Make sure writes are descending }
   LDS SI,DataPtr               { This has to be last access of memory
				  variable as DS is now altered }
   MOV CX,[SI]                  { Get width into CL, height into CH }
   INC SI
   INC SI                       { SI now points to actual shape data }


@Outer:
   MOV DI,BX                    { DI = Offset into VGA screen }
   MOV AL,CL                    { AL = Width of sprite }

   CMP AL,4                     { Bytes left < 4 ? }
   JB @MoveRemaining            { Yeah, so can't do the 4 Byte blit }

   SHR AL,2                     { Divide Bytes left by 4 }

@CopyLong:
   DB $66                       { Otherwise, store longword to [ES:DI] ! }
   MOVSW
   DEC AL                       { AL is long Word count }
   JNZ @CopyLong                { If AL <> 0 go back to CopyLong }

   TEST CL,3                    { Any remaining bytes to move ? }
   JZ @NoBytesLeft              { nah! }

   MOV AL,CL
   AND AL,3

@MoveRemaining:
   MOVSB                        { Store the remaining bytes }
   DEC AL
   JNZ @MoveRemaining


@NoBytesLeft:
   ADD BX,320                   { Advance BX to next scan line }
   DEC CH                       { Reduce Y count }
   JNZ @Outer                   { if <>0 then go to Outer }
   MOV DS,DX                    { Restore DS }

@StupidUser:
End;










{
Perform clipping calculations on an object.

Expects : AX to be an X coordinate for a sprite
	  BX to be a Y coordinate
	  ES:DI to point to the sprite data (NEWGRAPH format still)

Returns : If no draw can be done, carry is set TRUE.
	  Else carry is FALSE and :

	  ES: SI will point to first Byte to blit
	  DI will be the VGA screen offset for first blit, you
	  must change ES later.
	  CL is the number of bytes to blit ACROSS
	  CH is the number of bytes to blit DOWN
	  DX is the MODULO for the image (i.e. how many bytes SI should
	  skip (after reload) to get to the start of next row of
	  sprite data)

Affects : See above! ;)


Notes :   I suspect this routine isn't as fast as it could be, but then
	  again the logic behind the code was difficult to transform
	  to pure assembler, and I honestly couldn't be bothered
	  optimising this code just to get a few extra clock cycles
	  up on speed..
}


Procedure ClipCalculations; Near; Assembler;
Asm
   CMP AX,ViewWidth        { X > 319 ? }
   JGE @NoDraw              { Yes, Do not do any blits at all }

   CMP BX,ViewHeight       { Y > 199 ? }
   JGE @NoDraw              { JG is for SIGNED integers. If Y pos is
			     > ViewHeight then no blit needed }

   MOV SI,DI
   INC SI
   INC SI                  { Make SI point to actual sprite data }

   XOR CH,CH
   MOV CL,[ES:DI]          { CL holds Shapewidth }

   TEST AH,$80             { Is X negative ? (MSB set = yes) }
   JZ @XNotNegative        { If not then check if image is off right hand
			     of screen }

   NEG AX                  { Convert -X to X (temporarily) }
   CMP AX,CX               { If -X > ShapeWidth then don't draw }
   JA @NoDraw


   ADD SI,AX               { Bump SI to point to first pixel to blit }
   SUB CX,AX               { Reduce width by no of pixels off screen }
   INC CX                  { Adjust width in pixels }

   CMP CX,ViewWidth        { Is it STILL wider than the view screen, even
                             after trimming ? }
   JB @NoClipWidth
   MOV CX,ViewWidth
   DEC CX

@NoClipWidth:
   XOR AX,AX
   JMP @NowDoY



@XNotNegative:
   MOV DX,CX               { Set DX to clipwidth }
   ADD DX,AX               { If X + ClipWidth < ViewWidth Then }
   CMP DX,ViewWidth
   JB @NowDoY              { Do Y part (No need to clip X width) }

   MOV CX,ViewWidth
   SUB CX,AX               { ClipWidth = ViewWidth - X }




{
At this point:

AX is the X position of the Shape
BX is the Y position of the Shape
CL is the clipped width of the Shape.

Now it is time to do the height part and set the result in
CH.
}

@NowDoY:
   XOR DH,DH               { Make DX the height of image }
   MOV DL,[ES:DI+1]
   MOV CH,DL               { Set CH also to height for main blit routine }

   TEST BH,$80             { Quick test if Y position is negative }
   JZ @YNotNegative

{ If the routine comes here, y is negative }


   NEG BX                  { Make Y a positive number }

   CMP BX,DX               { If Y > ImageHeight }
   JA @NoDraw              { Don't draw image }

   SUB DX,BX               { Dec(ImageHeight, Abs(Y) ) }


   CMP DX,ViewHeight
   JB @NoClipHeight
   MOV DX,ViewHeight
   DEC DL


@NoClipHeight:
   MOV CH,DL

   PUSH AX                 { Save X Coord on stack }
   XOR AH,AH
   MOV AL,[ES:DI]          { AX = Width }
   MUL BX                  { Calculate Y * Width }
   ADD SI,AX               { Inc(DataStart, Abs(Y) * Width ) }
   POP AX
   XOR BX,BX               { Make Y coord 0 }
   JMP @NowDoBlit



{ On entry to this part, DX = Height of shape }

@YNotNegative:
   ADD DX,BX               { If Y + ClipHeight <= ViewHeight Then }
   CMP DX,ViewHeight
   JB @NowDoBlit          { Do blit }

   MOV DX,ViewHeight       { Else }
   SUB DX,BX               { ClipHeight = ViewHeight - Y }

   MOV CH,DL





{
At this point AX is the X position
	      BX is the Y position
	      CL is the ClipWidth and
	      CH is the ClipHeight.

As the width/height of a shape can only be an 8 bit
quantity (i.e. < 256) I can discard the H portions of
the registers. Whew!

Now follows some weird code.. I'm going to make :

DX = Modulo for datastart (which is the width in bytes of Shape.
And yes, I do know that Width could be held in DL but adding extra
code just to satisfy you optimisation junkies is v. boring.)

ES:SI = Points to sprite data (If you make DS:SI point to data,
	you can't access global variables, which I don't want to
	happen)
DI    = Offset on current bitmap of shape
}


@NowDoBlit:
   CALL CalculateOffset        { Use AX and BX to calculate screen
				 offset. On exit BX is offset }
   XOR DH,DH
   MOV DL,[ES:DI]              { DX = Modulo }
   MOV DI,BX                   { Ahhh. Now DI points to the screen offset }
   CLC
   RET

@NoDraw:
   STC                         { Indicate no blit possible }

End;









{
This routine does the same as Blit but takes into account
the fact that the sprite may be off the edges of the
screen.

Its quite a bit slower than the normal Blit, but that's only
to be expected as there's more computations to be
done.

Expects  : X, Y specify the horizontal and vertical position of the Shape,
	   DataPtr points to the data to blit.

Returns  : Nothing

Affects  : AX,BX,CX,DX,SI,DI,ES,Direction Flag.
}



Procedure ClipBlit(x,y:Integer; Var DataPtr); Assembler;
Asm
   MOV AX,X
   MOV BX,Y
   LES DI,DataPtr
   CALL ClipCalculations
   JC @NoDraw

   PUSH DS                     { Save essential regs }
   PUSH BP                     { Don't want to corrupt BP now do we :) }

   MOV AX,CurrentBitmapSegment
   MOV BX,ES
   MOV DS,BX                   { Now DS: SI points to correct space }
   MOV ES,AX

   MOV BX,SI                   { BX to be used to reload SI }
   MOV BP,DI                   { And the screen modulo }
   MOV AH,CL                   { AH = Width }
   CLD                         { Make sure LODSB works OK }

@Outer:
   MOV CL,AH                   { Re-load CL }
   MOV SI,BX                   { And SI with address of next sprite row }
   MOV DI,BP                   { And DI with address of next scan line }


@WriteByte:
   LODSB                       { Read Byte from DS:SI }
   OR AL,AL                    { Is Byte 0 (transparent) ? }
   JZ @NoBlit                  { yes, so don't blit }
   MOV [ES:DI],AL              { Otherwise store Byte }

@NoBlit:
   INC DI                      { Move DI to next pos. on screen }
   DEC CL                      { Reduce shape width count }
   JNZ @WriteByte              { If not zero, end of shape not reached }

   ADD BX,DX                   { BX = BX + Modulo, so BX now points
				 to first Byte of next sprite line
				 to blit }
   ADD BP,320                  { Make BP point to next line. Note :
				 If you are going to add some extra
				 stuff here make sure you're not
				 accessing local variables! }
   DEC CH
   JNZ @Outer

   POP BP
   POP DS

@NoDraw:
End;









{
This routine does the same as Block except that it takes into account
that the shape object may be off screen.

Expects  : Same as Block.

Returns  : Nothing

Affects  : AX,BX,CX,DX,SI,DI,ES,Direction Flag.
}



Procedure ClipBlock(x,y:Integer; Var DataPtr); Assembler;
Asm
   MOV AX,X
   MOV BX,Y
   LES DI,DataPtr               { ES:DI points to data }
   CALL ClipCalculations
   JC @NoDraw

   PUSH DS
   PUSH BP

   MOV AX,CurrentBitmapSegment
   MOV BX,ES
   MOV DS,BX                    { Now DS: SI points to correct space }
   MOV ES,AX

   MOV BX,SI                    { BX to be used to reload SI (+Image Width) }
   MOV BP,DI                    { And BP to reload DI (+Screen Width) }
   CLD                          { Make sure LODSB works OK }

@Outer:
   MOV AL,CL                    { AL is set to ClipWidth }
   MOV SI,BX
   MOV DI,BP

   CMP AL,4                     { Bytes left < 4 ? }
   JB @MoveRemaining            { Yeah, so can't do the longword blit }
   SHR AL,2                     { Divide Bytes left by 4 }

@CopyLong:
   DB $66                       { Otherwise, store longword to [ES:DI] ! }
   MOVSW
   DEC AL                       { Reduce long Word count }
   JNZ @CopyLong

   TEST CL,3
   JZ @NoBytesLeft

   MOV AL,CL                    { As AL is faster }
   AND AL,3

@MoveRemaining:
   MOVSB
   DEC AL
   JNZ @MoveRemaining

@NoBytesLeft:
   ADD BX,DX                    { BP to next Byte of image to read }
   ADD BP,320                   { Advance BX to next scan line }

   DEC CH                       { Reduce Y count }
   JNZ @Outer                   { if <>0 then go to Outer }

   POP BP                       { Restore base Pointer and }
   POP DS                       { Data Segment }

@NoDraw:
End;











{
Grab a rectangular area of bytes from the Current Bitmap for use
as a shape object.


Expects     : X1,Y1 define the TOP LEFT of the area to grab.
	      X2,Y2 define the BOTTOM RIGHT of the area.

	      X1 MUST be less than X2;
	      Similarly, Y1 MUST be less than Y2.

	      Also, it is NOT possible to grab an image that
	      is more than 255 pixels wide and 200 pixels
	      high.

Returns     : Nothing

Notes       : Use the ExtShapeSize or ShapeSize Functions to
	      calculate bytes needed to hold shape object in
	      memory .

	      An example:

	      GetMem(shapeptr,ShapeSize(0,0,15,15));
	      GetAShape(0,0,15,15,ShapePtr^);
	      Blit... etc etc.
	      FreeShape(shapeptr);


Affects     : AX,BX,CX,DX,SI,DI,ES
}


Procedure GetAShape(x1,y1,x2,y2:Word;Var DataPtr); Assembler;
Asm
   MOV AX,x1
   MOV BX,y1
   CALL CalculateOffset
   JC @StupidUser

   MOV AX,x2                    { Width = (X2 - X1) +1 }
   SUB AX,x1
   INC AL                       { Take into account extra pixel }
   MOV CL,AL

   MOV AX,y2                    { Height = (Y2 - Y1) +1 }
   SUB AX,y1
   INC AL
   MOV CH,AL

   LES DI,DataPtr
   MOV [ES:DI],CX               { Store Width & Height }
   INC DI
   INC DI

   MOV DX,DS
   MOV DS,CurrentBitmapSegment
   CLD                          { Make sure writes are descending }

@Outer:
   MOV SI,BX                    { SI = Offset into VGA screen }
   MOV AL,CL                    { AL = Width of sprite held in CL }

   CMP AL,4                     { Bytes left < 4 ? }
   JB @MoveRemaining            { Yeah, so can't do the 4 Byte blit }

   SHR AL,2                     { Divide Count by 4 }

@CopyLong:
   DB $66                       { Otherwise, store longword to [ES:DI] ! }
   MOVSW
   DEC AL                       { CL is long Word count }
   JNZ @CopyLong                { If CL <> 0 go back to CopyLong }

   TEST CL,3
   JZ @NoBytesLeft

   MOV AL,CL
   AND AL,3

@MoveRemaining:
   MOVSB                        { Write remaining bytes }
   DEC AL
   JNZ @MoveRemaining


@NoBytesLeft:
   ADD BX,320                   { Advance BX to next scan line }
   DEC CH                       { Reduce Y count }
   JNZ @Outer                   { if <>0 then go to Outer }
   MOV DS,DX                    { Restore data segment }

@StupidUser:
End;












{
This routine checks if the data contained within a Shape will
"Collide" with the background. (Background data is held within
the Current Bitmap)

This command is very useful for games that need accurate
Shape to background collision detection.

Expects  : X and Y specify the horizontal and vertical position
	   of a shape pointed to by DataPtr.

Returns  : If the Shape has collided with ANY background (represented
	   by colours 1-255) on the Current Bitmap then BlitColl is TRUE.

Affects  : EAX,BX,CX,DX,SI,DI,ES
}



Function BlitColl(x,y :Integer; Var dataptr) : boolean; Assembler;
Asm
   MOV AX,x
   MOV BX,y
   CALL CalculateOffset         { On exit, BX will hold screen "Offset" }
   JC @NoCollision

   MOV ES,CurrentBitmapSegment
   PUSH DS
   PUSH BP                 { Save BP as it's a lovely reg :) }

   LDS SI,DataPtr


   MOV DX,[SI]             { DL= Width, DH = Height }
   INC SI
   INC SI                  { Make SI point to sprite data }
   CLD                     { Make sure writes are descending }
   MOV CL,DL

@Outer:
   MOV DI,BX               { DI = Offset into Current Bitmap }
   MOV DL,CL

{ Check if any long words can be moved }

   CMP DL,4                { Is width at least 4 bytes ? }
   JB @CantCheckLong       { No }
   SHR DL,2                { Otherwise, divide width by 4 so that
			     DL will hold number of LONGs to check }

@CheckLong:
   DB $66; LODSW           { LODSD : Load EAX from DS:SI }
   DB $66; OR AX,AX        { OR EAX,EAX }
   JZ @NoCheckBackLong     { If EAX is zero then no point in checking
			     background is there ? }

   DB $66
   MOV BP,AX               { Make a copy of EAX }
   DB $66
   XOR AX,[ES:DI]          { XOR EAX, [ES:DI]  (Xor EAX with Background) }
   DB $66
   CMP BP,AX               { Is EAX unaffected by the XOR - i.e.
			     No collision }
   JNZ @CollisionOccurred


@NoCheckBackLong:
   ADD DI,4                { Bump DI to next long Word }
   DEC DL                  { Reduce long Word count }
   JNZ @CheckLong          { And now do the collision check for long Word }



   MOV DL,CL               { Restore DL to it's previous contents }
   AND DL,3                { Mask out all but bits 0 & 1 }


{ Any words left to be checked ? }

@CantCheckLong:
   CMP DL,2                { Is there at least 2 bytes left to move ? }
   JB @CantCheckWord       { No }

@CheckWord:
   LODSW                   { Read Word from DS:SI into AX }
   OR AX,AX                { Is Shape data zero ? }
   JZ @CantCheckWord       { Yes, so can't be a collision }

   MOV BP,AX
   XOR AX,[ES:DI]          { Otherwise, check background too }
   CMP BP,AX               { Is AX different ? }
   JNZ @CollisionOccurred  { Yes, so this means a collision }
   ADD DI,2                { Otherwise move to next Word }

@CantCheckWord:
   TEST CL,1               { Is there a single Byte left to check }
   JZ @AllChecksDone       { Nope }
   LODSB                   { Otherwise, read it }
   OR AL,AL                { Zero ? }
   JZ @AllChecksDone       { Yes, so basically no more checks to do }

   MOV CH,AL
   XOR AL,[ES:DI]          { No, so check background Byte }
   CMP CH,AL               { Is AL different ? }
   JNZ @CollisionOccurred  { Yes, so a collision has occurred }


@AllChecksDone:
   ADD BX,320              { 320 is the number of bytes in one scan-line }
   DEC DH                  { Reduce vertical count (Counts from height of
			     Shape) }
   JNZ @Outer              { If <>0 then check for next line of Shape }

@NoCollision:
   MOV AL,False            { If all lines have been done then this means
			     that no collision has occurred }

   JMP @Exit               { And exit. Don't insert a RET here -
			     you'll crash the program ! }

@CollisionOccurred:
   MOV AL,True             { This part is only reached if a collision has
			     occurred. }

@Exit:
   POP BP                  { Restore Base Pointer }
   POP DS                  { Restore data segment }
End;














{
Scale a shape object (as if you hadn't guessed) :)
Code originally by Sean Palmer, optimised and converted into
32 bit assembler by Scott Tunstall.

A question Sean: did you figure the algorithm out by yourself?
If you did you must be a genius mate :)



Expects : DataPtr^ points to the shape to scale
	  x1,y1,x2,y2 defines the window on the Current Bitmap
	  where the sprite will be scaled TO.

Returns : Nothing


Affects : AX,BX,CX,DX,SI,DI,ES
}




Procedure ScaleShape(var DataPtr; x1:Word;y1:Byte;x2:Word;y2:Byte);
assembler;

type
  fixed = record
    case boolean of
      true  : (w : longint);
      false : (f, i : Word);
    end;

var
  x,y        : Word;              { Makes those muls easier }
  s, w, h    : Word;
  sx, sy, cy : fixed;

asm
     MOV SI, WORD PTR DataPtr
     MOV ES, WORD PTR DataPtr+2

     XOR AH,AH                    { Get shape width into X }
     MOV AL,[ES:SI]
     MOV x,AX
     INC SI

     MOV AL,[ES:SI]               { Get shape height into Y }
     MOV y,AX
     INC SI

     MOV AX,x1
     XOR BH,BH
     MOV BL,y1
     CALL CalculateOffset
     JC @StupidUser               { No clipping available for
				    this baby ! =) }
     MOV DI,BX
     MOV BX,x2
     XCHG AX,BX                   { AX = X2, BX = X1 }
     SUB AX,BX
     INC AX
     MOV CX,AX
     MOV w,AX                     { Save width }

     MOV AX,320                   { s = 320 - w }
     SUB AX,CX
     MOV s,AX

     XOR DX,DX                    { Make DX:AX = 65536 }
     INC DL
     XOR AX,AX
     DIV CX                       { 65536 / w }

     MUL x                        { * x }
     MOV WORD [sx.w],AX
     MOV WORD [sx.w+2],DX

     XOR AH,AH                    { Calc (y2 - y1) + 1 }
     MOV AL,y2
     SUB AL,y1
     INC AL
     MOV h,AX                     { h = result }
     MOV BX,AX

     XOR DX,DX                    { Make DX:AX = 65536 }
     INC DL
     XOR AX,AX
     DIV BX                       { 65536 / h }
     MUL y                        { * y }
     MOV WORD [sy.w],AX
     MOV WORD [sy.w+2],DX

     DB $66; MOV WORD PTR cy.w, 0
     DW 0

     PUSH DS

     MOV AX,ES
     MOV ES,CurrentBitmapSegment
     MOV DS,AX




{
At this point

   CX    = width
   DX    = height
   DS:SI = points to top left of shape
   ES:DI = points to Address on screen where scaled shape
	   will be placed
}


    cld


@L2:

    PUSH SI                     { A Push IS faster than using the MSW
				  of a 32 bit reg! Strange eh? }

    MOV  AX, cy.i
    MUL  X                      { It would have been nice if intel
				  created a 16 bit MUL which didn't
				  f**k up DX }
    ADD  SI,AX                  { Get proper start of sprite data }
    PUSH CX

    XOR  BX, BX
    MOV  DX, sx.f

@L:
    MOV AL,[SI]                 { Get Byte from shape }
    STOSB                       { And write to bitmap }

    ADD  BX, DX
    ADC  SI, sx.i               { if carry or sx.i<>0,
				  new source pixel }

    DEC CX
    JNZ @L

    POP CX
    POP SI                      { Restore Sprite data ptr }

    ADD  DI, s                  { skip to next screen row}
    DB $66; MOV  AX, sy.f       { MOV EAX, sy.f }
    DB $66; ADD  cy.f, AX       { ADD DWORD PTR cy.f, EAX }

    DEC  WORD PTR h
    JNZ  @L2
    POP  DS

@StupidUser:
end;













{
THANK GOD FOR BLOCK COPYING :)

Scale a shape object (as if you hadn't guessed) with colour 0
transparency masking (in other words, colour 0 isn't written,
and the background is displayed instead)


Expects : DataPtr^ points to the shape to scale
	  x1,y1,x2,y2 defines the window on the Current Bitmap
	  where the sprite will be scaled TO.

Returns : Nothing


Affects : AX,BX,CX,DX,SI,DI,ES
}




Procedure ScaleMskShape(var DataPtr; x1:Word;y1:Byte;x2:Word;y2:Byte);
assembler;

type
  fixed = record
    case boolean of
      true  : (w : longint);
      false : (f, i : Word);
    end;

var
  x,y        : Word;              { Makes those muls easier }
  s, w, h    : Word;
  sx, sy, cy : fixed;

asm
     MOV SI, WORD PTR DataPtr
     MOV ES, WORD PTR DataPtr+2

     XOR AH,AH                    { Get shape width into X }
     MOV AL,[ES:SI]
     MOV x,AX
     INC SI

     MOV AL,[ES:SI]               { Get shape height into Y }
     MOV y,AX
     INC SI

     MOV AX,x1
     XOR BH,BH
     MOV BL,y1
     CALL CalculateOffset
     JC @StupidUser               { No clipping available for
				    this baby ! =) }
     MOV DI,BX
     MOV BX,x2
     XCHG AX,BX                   { AX = X2, BX = X1 }
     SUB AX,BX
     INC AX
     MOV CX,AX
     MOV w,AX                     { Save width }

     MOV AX,320                   { s = 320 - w }
     SUB AX,CX
     MOV s,AX

     XOR DX,DX                    { Make DX:AX = 65536 }
     INC DL
     XOR AX,AX
     DIV CX                       { 65536 / w }

     MUL x                        { * x }
     MOV WORD [sx.w],AX
     MOV WORD [sx.w+2],DX

     XOR AH,AH                    { Calc (y2 - y1) + 1 }
     MOV AL,y2
     SUB AL,y1
     INC AL
     MOV h,AX                     { h = result }
     MOV BX,AX

     XOR DX,DX                    { Make DX:AX = 65536 }
     INC DL
     XOR AX,AX
     DIV BX                       { 65536 / h }
     MUL y                        { * y }
     MOV WORD [sy.w],AX
     MOV WORD [sy.w+2],DX

     DB $66; MOV WORD PTR cy.w, 0
     DW 0

     PUSH DS

     MOV AX,ES
     MOV ES,CurrentBitmapSegment
     MOV DS,AX




{
At this point

   CX    = width
   DX    = height
   DS:SI = points to top left of shape
   ES:DI = points to Address on screen where scaled shape
	   will be placed
}




@L2:

    PUSH SI                     { Spot the block-copying in absence of
                                  macros }

    MOV  AX, cy.i
    MUL  X                      { It would have been nice if intel
				  created a 16 bit MUL which didn't
				  f**k up DX }
    ADD  SI,AX                  { Get proper start of sprite data }
    PUSH CX

    XOR  BX, BX
    MOV  DX, sx.f

@L:
    MOV AL,[SI]                 { Get Byte from shape }
    OR AL,AL                    { If it's non zero... ? }
    JZ @NextByte
    MOV [ES:DI],AL              { Write it to screen }


@NextByte:
    INC DI
    ADD  BX, DX
    ADC  SI, sx.i               { if carry or sx.i<>0, new source pixel }

    DEC CX
    JNZ @L

    POP CX
    POP SI                      { Restore Sprite data ptr }

    ADD  DI, s                  { skip to next screen row}
    DB $66; MOV  AX, sy.f       { MOV EAX, sy.f }
    DB $66; ADD  cy.f, AX       { ADD DWORD PTR cy.f, EAX }

    DEC  WORD PTR h
    JNZ  @L2
    POP  DS

@StupidUser:
end;















{
This routine flips a shape object horizontally. The original shape object
is replaced with it's mirror image.


Expects : DataPtr^ points to the shape object to flip.

Returns : Nothing

Affects : AX, BX, CX, DX, SI, DI

}



Procedure XFlipShape(Var DataPtr); Assembler;
Asm
     PUSH DS
     LDS SI,DataPtr

     XOR DH,DH          { DX = Modulo (Used to get from 1 line to next) }
     MOV DL,[SI]
     MOV CL,DL
     INC SI
     MOV CH,[SI]
     INC SI             { SI now points at actual shape data }

     MOV DI,SI
     ADD DI,DX          { DI will point to next row, which we don't
			  want, but DI gets adjusted later }

     CMP CL,4           { If less 4 bytes per line on shape }
     JB @SmallShape     { Call the rather sexy small shape handler }

     SUB DI,2
     SHR CL,2           { Otherwise divide width by 2 }



@Outer:
     PUSH SI
     PUSH DI


@SwapBytes:

     MOV AX,[SI]        { Read bytes from beginning of line }
     XCHG AL,AH         { Swap the two around }
     MOV BX,[DI]        { Read bytes from end of line }
     XCHG BL,BH         { Swap them around }

     MOV [SI],BX
     MOV [DI],AX
     INC SI             { Move to next bytes }
     INC SI
     DEC DI             { Move to previous bytes }
     DEC DI
     DEC CL             { Reduce X counter which is #Words on sprite line }
     JNZ @SwapBytes


{ An easy way of finding out whether a middle Byte exists is to check
  if (DI - SI) = 1 as SI & DI are postincremented/decremented during
  Word swaps. When the count in CL reaches zero, DI should be less than
  SI. If it is not then a single Byte on either side of the middle Byte
  remain to be swapped.

}


     CMP DI,SI
     JB @NoMiddleByte
     INC DI
     MOV AL,[SI]
     XCHG AL,[DI]       { Perform swap of bytes next to middle Byte }
     MOV [SI],AL

@NoMiddleByte:
     POP DI
     POP SI


     MOV CL,DL          { Get shape width which was saved in DL }
     SHR CL,2           { Divide shape width by 4 again }

     ADD SI,DX          { Now move to start of next sprite line }
     ADD DI,DX          { Move to end of next sprite line }

     DEC CH
     JNZ @Outer
     JMP @ExitProg


{
This part of the program handles really small shapes which are less than
4 pixels wide. I have never used < 4 pixel wide sprites in my software
but I guess some of you might, so....
}


@SmallShape:
     DEC DI

@Outer2:
     MOV AL,[SI]        { This should be easy to suss }
     MOV AH,[DI]
     MOV [DI],AL
     MOV [SI],AH
     ADD SI,DX
     ADD DI,DX
     DEC CH
     JNZ @Outer2


@ExitProg:
     POP DS
End;









{
Mirror shape vertically, so that it looks upside down.

Expects : DataPtr^ points to the shape object to flip.

Returns : Nothing

Affects : EAX, BX, CX, DX, SI, DI
}





Procedure YFlipShape(Var DataPtr); Assembler;
Asm
   PUSH DS
   LDS SI,DataPtr

   PUSH BP

   MOV AX,[SI]         { AL = Width of shape, AH = Height }
   INC SI
   INC SI

   XOR DH,DH           { DX = Modulo, to get to next line }
   MOV DL,AL

   MOV CH,AH
   SHR CH,1            { Divide height by 2 }


   DEC AH              { Want to get to start of last line
			 of sprite }

   MUL AH
   ADD AX,SI
   MOV DI,AX           { DI points to start of last sprite
			 line }


@Outer:
   MOV BP,SI           { Make BP point to next line from SI }
   ADD BP,DX
   MOV BX,DI           { Make BX point to previous line from DI }
   SUB BX,DX


   MOV CL,DL                   { Check width of shape }
   CMP CL,4                    { Shape have any long words ? }
   JB @NoLongsToSwap
   SHR CL,2                    { Yeah, so get long Word count }

@SwapLong:
   DB $66; MOV AX,[SI]         { Swap long words }
   DB $66; XCHG AX,[DI]
   DB $66; MOV [SI],AX
   ADD SI,4                    { Move to next long Word }
   ADD DI,4
   DEC CL                      { Repeat until all long words done }
   JNZ @SwapLong

   MOV CL,DL
   AND CL,3
   OR CL,CL
   JZ @NoMoreSwaps

@NoLongsToSwap:
   MOV AL,[SI]                 { Swap remaining bytes }
   XCHG AL,[DI]
   MOV [SI],AL
   INC SI
   INC DI

   DEC CL
   JNZ @NoLongsToSwap

@NoMoreSwaps:
   MOV SI,BP
   MOV DI,BX


   DEC CH
   JNZ @Outer


   POP BP
   POP DS
End;











{
De-allocate memory for a shape.

Expects  : DataPtr is a shape Pointer.

Returns  : Nothing

Affects  : The assembler part uses AX,DI and ES. Don't know about
	   the Pascal part however. Assume that all registers (
	   except of course DS & SS) are corrupted.

Notes    : Isn't FreeMem a pile of shit ?
	   Even DOS manages to free mem with you only passing a
	   Pointer :)
}

Procedure FreeShape(DataPtr:Pointer);
Begin
     FreeMem( DataPtr,ExtShapeSize(ShapeWidth(DataPtr^),
	      ShapeHeight(DataPtr^)));
End;







{
Load in a .IMG (shape) file from disk.

WARNING! This is NOT the IMG file type used by some paint packages!
It is a non-standard file (albeit very simple) format that KOJAKVGA
(and NEWGRAPH) writes.


Expects  :  FileName to be a valid MS-DOS path.
	    DataPtr to be a valid Pointer to where data will be stored.

Returns  :  Exits with error message if specified shape doesn't
	    exist on disk or if no memory can be allocated for shape.
	    ( I realised no-one uses continuous sprite loading during
	    game execution any more :) )

	    If shelling the program which loads shapes, an error code
	    of <1> shall be returned as the error level.


Affects  :  Don't know. Let me see: err, AX yup, BX, CX, DX,
	    how long have you got to debug the compiled code? ;)
}



Procedure LoadShape(FileName:String; Var DataPtr: Pointer);

Var F            : File;
    ShapeBuf     : ShapeHeader;
    ImgSize      : Word;


Begin
     Assign(F,FileName);


{ I decided to add validation here :) }

     {$i-}
     Reset(F,1);
     {$i+}

     if IoResult = 0 Then
	Begin
	BlockRead(F,shapebuf,sizeof(shapeheader));


	{
	Calculate number of bytes that need to be reserved for the
	Shape in memory.
	}

	ImgSize:= ExtShapeSize( ShapeBuf.ShapeWidth, ShapeBuf.ShapeHeight);

	If ImgSize < MaxAvail Then
	   Begin
	   GetMem(DataPtr,ImgSize);
	   Seek(F,0);
	   BlockRead(F,DataPtr^, ImgSize);
	   Close(F);
	   End
	Else
	    Begin
	    Writeln('Error: Not enough memory to load shape ',FileName,'.');
	    Halt(1);
	    End;
	End
     Else
	 Begin
	 Writeln('Error: Shape file ',FileName,' does not exist.');
	 Halt(1);
     End;

End;














{
Write a shape to disk, where you could convert it if you like
to a PCX.

Expects  :  FileName is a standard DOS filename.
	    P is a Pointer to where the sprite data exists in memory.

Returns  :  Nothing.

Affects  :  All 16 bit registers except DS & SS I'd bet.
}



Procedure SaveShape(FileName:string; DataPtr:Pointer);
Var F: File;

Begin
     Assign(F,FileName);
     Rewrite(F,1);
     BlockWrite(F, DataPtr^, extshapesize(shapewidth(DataPtr^),
		   shapeheight(DataPtr^)));
     Close(F);
End;









{
Now you can save a shape object and attach a variable sized
palette to it, so that you can have a different palette for
each sprite if you desire. (Added October 25th 1996 for V3.2)

Of course,a shape changing the entire palette each time it's loaded
could really piss you off, especially if the shape only uses a few
colours. SO, I've decided to allow you to save a range of
palette colours with the shape.

For example, say the shape object used colours 250 thru 255.
The range you'd specify for parameters <First, Second>
respectively would be (this is SOOOOO obvious)

    250,255

Next obvious statement: This indicates to the KOJAKVGA shape loader
that palette entries from 250 to 255 are affected.

Note: 0,255 would mean "save entire palette" but you'd be better off
      using the SavePalette command wouldn't you?


Expects : FileName is obvious.
	  DataPtr points to the shape to save.
	  First, Second indicates the range of colours to save.
	  (0-255)

Returns : Nothing

Affects : Everything except DS & SS I suppose.
}



Procedure SaveShapeWithPalette( FileName:string; DataPtr:Pointer;
				Var ThePalette: PaletteType;
				First, Second:Byte);


Var F           : File;
    Count       : Byte;
    IDStr       : longint;
    RedVal,
    GreenVal,
    BlueVal     : Byte;



Begin
     Assign(F,FileName);
     Rewrite(F,1);
     BlockWrite(F, DataPtr^,
		   extshapesize(shapewidth(DataPtr^),
		   shapeheight(DataPtr^)));

     { Now attach palette }

     IDStr:=SHP_PAL_ATTACHED;
     BlockWrite(F,IDStr,4);               { To signify that there IS a
					  palette attached}
     BlockWrite(F,First,1);               { Specify affected colours }
     BlockWrite(F,Second,1);

     With ThePalette Do
     For Count:=First To Second do
	 Begin
	 BlockWrite(F,RedLevel[Count],1);
	 BlockWrite(F,GreenLevel[Count],1);
	 BlockWrite(F,BlueLevel[Count],1);
     End;


     Close(F);
End;









{ Added 8th November 1996

  This determines if a shape file does have an attached palette.

  Expects: FileName is obvious!

  Returns: TRUE if shape file does have an attached palette.
	   Your program halts if the specified file does not
	   exist (Error level 1 returned to parent process)

  Affects: Definitely not DS & SS!

}


Function ShapeFileHasPalette(FileName:string): boolean;
Var F        : File;
    ShapeBuf : ShapeHeader;
    IDStr    : Longint;

Begin
     ShapeFileHasPalette:=False;
     Assign(F,FileName);

     {$I-}
     Reset(F,1);
     {$I+}

     If IoResult=0 Then
	Begin
	BlockRead(F,ShapeBuf,SizeOf(ShapeHeader));
	Seek(F, SizeOf(ShapeHeader)+( ShapeBuf.ShapeWidth *
				      ShapeBuf.ShapeHeight));
	if not eof (F) Then
	   Begin
	   BlockRead(F,IDStr,4);
	   If IDStr = SHP_PAL_ATTACHED Then
	      ShapeFileHasPalette:=True;
	   End;
	End
     Else
	 Begin
	 Writeln('Error: Cannot inspect shape file ',FileName,'.');
	 Halt(1);
     End;
End;








{
Load a shape that has an attached palette. (Added 25th October 1996 for
V3.2)


Expects  : FileName is obvious!
	   DataPtr points to where the shape shall be stored.
	   ThePalette is the palette object which shall be updated
	   by the shape's palette information. (Only colours that
	   were saved with the shape shall be altered, so if you
	   SaveShape with a range 127-255 colours 0-126 in the
	   ThePalette object shall be unaffected)

Returns  : Nothing

Affects  : Everything except DS & SS probably...

}


Procedure LoadShapeWithPalette( FileName: string; Var DataPtr: Pointer;
				Var ThePalette: PaletteType);

Var F            : File;
    ShapeBuf     : ShapeHeader;
    ImgSize      : Word;
    IDStr        : longint;
    First        : Byte;
    Second       : Byte;
    Count        : Byte;


Begin
     Assign(F,FileName);


{ I decided to add validation here :) }

     {$i-}
     Reset(F,1);
     {$i+}

     if IoResult = 0 Then
	Begin
	BlockRead(F,shapebuf,sizeof(shapeheader));


	{
	Calculate number of bytes that need to be reserved for the
	Shape.
	}

	ImgSize:= ExtShapeSize( ShapeBuf.ShapeWidth,
				ShapeBuf.ShapeHeight);

	If ImgSize < MaxAvail Then
	   Begin

	   GetMem(DataPtr,ImgSize);
	   Seek(F,0);
	   BlockRead(F,DataPtr^, ImgSize);


	   { Didn't I say about extreme nesting :) ? }

	   if not eof (F) Then
	      Begin
	      BlockRead(F,IDStr,4);
	      If IDStr = SHP_PAL_ATTACHED Then
		 Begin
		 BlockRead(F,First,1);
		 BlockRead(F,Second,1);

		 With ThePalette Do
		 For Count:=First To Second Do
		     Begin
		     BlockRead(F,RedLevel[Count],1);
		     BlockRead(F,GreenLevel[Count],1);
		     BlockRead(F,BlueLevel[Count],1);
		     End;
		 End
	      Else
		  Begin
		  Writeln('Error: Palette format unknown with shape ',FileName,'.');
		  Halt(1);
		  End;
	      End
	   Else
	       Begin
	       Writeln('Error: No palette attached to ',FileName,'.');
	       Halt(1);
	       End;


	   Close(F);
	   End
	Else
	    Begin
	    Writeln('Error: Not enough memory to load shape ',FileName,'.');
	    Halt(1);
	    End;
	End
     Else
	 Begin
	 Writeln('Error: Couldn''t find shape file ',FileName,'.');
	 Halt(1);
     End;

End;















{
====================================================================


	       FAST PCX LOAD AND SAVE ROUTINES


--------------------------------------------------------------------
}




{

This PCX loader can handle PCX's larger than 64K in file size
and dimensions beyond 320 x 200, although only up to <ViewWidth> x
<ViewHeight> will be shown.


Expects: Filename is an MS-DOS filespec relating to the PCX's name.

         TheBitmap points to a 64K region. (Use New64KBitmap func
         to allocate a bitmap the safe way).

	 ThePalette is a PaletteType record used to hold the PCX's
	 palette data.

	 X,Y specifies the top left coordinates relative to the
	 current window where the PCX is to be drawn. Do NOT
	 specify an X/Y coordinate which is off window limits
	 or your PC will (in all likelihood) crash.

	 WidthToShow can be a number between 1 and (GetMaxX+1),
	 HeightToShow can be between 1 and (GetMaxY+1)
	 The picture will be clipped as necessary.

Returns: Your program will halt with an error message if the PCX file
	 does not exist, or if the PCX is not of the correct "type".
	 (I.E. It's not 256 colour)

	 Note: Unlike lesser PCX routines, this proc can load PCXs
	 occupying more than 64K disk space and larger than
	 320 x 200 in size, but it only shows the image to 320 x 200
	 dimensions.


Affects: Definitely DI, ES. Not sure about the other registers.
}



Procedure LoadPCXToBitmap( filename:string; TheBitmap: Pointer;
                     Var ThePalette: PaletteType;
	             x,y,widthtoshow,heighttoshow:Word);

Var
    Count           : Byte;
    RedVal          : Byte;         { Used for ColourMap, Palette values }
    GreenVal        : Byte;         { which define a colour }
    BlueVal         : Byte;

    DstBMapSeg,                     { Bitmap Where PCX is written to }
    DstBMapOffs     : Word;         { Screen offset }

    Width,Height,                   { Width is number of horizontal bytes to grab
				      Height is number of vertical bytes to grab }
    N,Bytes         : Word;         { N counts up to Bytes }
    RunLength,c     : Byte;         { RunLength is the Run Length Encoding
				      Byte, C is the character read from
				      PCX data }
    PastHorizontalLimit : boolean;  { Set true this means no more
				     horizontal pixel writes to do, advance
				     to next line as soon as poss.}

begin
     If InitCache(FileName,IOReadLater,MaxAvail) >0 Then
       Begin
       CacheSeek(0);
       GetStructFromCache(header,sizeof(header));

       if (header.manufacturer=10) and (header.version=5) and
	  (header.bits_per_pixel=8) and (header.colour_planes=1) then
       begin
            Cacheseek (GetCachefilesize-769);     { Move to palette data }
            GetByte(C);                             { Get colormap type }
	    if (c=12) then                          { 12 is correct type }
	    begin
	         {
		 Read palette data and write to palette
		 structure.
		 }

		 for Count:=0 to 255 do
		 Begin
                       GetByte(RedVal);
                       GetByte(GreenVal);
                       GetByte(BlueVal);
		       ThePalette.RedLevel[Count]:=RedVal SHR 2;
		       ThePalette.GreenLevel[Count]:=GreenVal SHR 2;
		       ThePalette.BlueLevel[Count]:=BlueVal SHR 2;
		 End;


		 Cacheseek (128);


		 {
		 Find out width & height of PCX.
		 }

		 With Header Do
		 Begin
		      width:=(xmax - xmin)+1;
		      height:=(ymax - ymin)+1;
		      bytes:=bytes_per_line;
		 End;


		 {
		 Adjust width & height of PCX if necessary so that PCX
		 "fits" in the current window.
		 }

		 if widthtoshow > width Then
		    widthtoshow:=width;

		 if (x+widthtoshow) > Viewwidth Then
		    widthtoshow:=ViewWidth-x;

		 if heighttoshow > height Then
		    heighttoshow:=height;

		 if (y+heighttoshow) > Viewheight Then
		    heighttoshow:=Viewheight-y;


		 { VALIDATION FREE ZONE FROM NOW ON :) }

		  Asm
                  LES DI,TheBitmap

                  MOV AX,X
                  MOV BX,Y
                  CALL NoWinCalculateOffset
                  ADD DI,BX
                  MOV DstBMapSeg,ES
                  MOV DstBMapOffs,DI
		  End;


		  for Count:=1 to heighttoshow do
		  begin
		      n:=0;
		      PastHorizontalLimit:=False;

{ Normally I wouldn't do this, but hell why not eh? Faster than
  fannying around with local variables :)
}

		      Asm PUSH DstBMapOffs end;

		      while (n<bytes) do
		      begin

			   { Display any more pixels width wise from PCX ? }

			   If (n>= WidthToShow) Then
			      PastHorizontalLimit:=True;


                           { Hope we don't hit errors }

                           GetByte(c);


			    if ((c and 192)=192) then
			    begin

			       { Get the 6 least significant bits }
			       RunLength:=c and 63;

			       { get the run Byte }

                               GetByte(c);


			       {
			       Can't do blit if past the horizontal limit
			       of the window.
			       }

			       If Not PastHorizontalLimit Then
				  Begin
				  If n+RunLength > widthtoshow Then
                           	     fillchar(Mem[DstBmapSeg:DstBMapOffs],WidthToShow-n,c)

				  else
				      fillchar(Mem[DstBmapSeg:DstBMapOffs],RunLength,c);

				  inc(DstBMapOffs,RunLength);
			       End;

			       inc(n,RunLength);
			       end
			    else
				begin
				If Not PastHorizontalLimit Then
				   Begin
				   mem [DstBMapSeg:DstBMapOffs]:=c;
				   inc (DstBMapOffs);
				End;
				inc (n);
			    end;

		      end;


		      { Ahem :) }

		      Asm
			  POP DstBMapOffs
			  ADD DstBMapOffs,320
		      End;

		  end;

	       end
	  else
	      Begin
	      DirectVideo:=False;
	      Writeln('Error: PCX file ',FileName,
	      's ColourMap is not of required type.');
              CloseCache;
	      Halt(1);
	      End;
	  end
       Else
	   Begin
	   DirectVideo:=False;
	   Writeln('Error: PCX file ',FileName,
	   ' is not a 256 colour PCX.');

           CloseCache;
	   Halt(1);
       End;

       CloseCache;

       end
    Else
	Begin
	DirectVideo:=False;
	Writeln('Error: PCX File ',FileName,' not found.');
	Halt(1);
	End;
End;











{
This will put a mode 13h 256 colour PCX at position X,Y and
show a defined area.




Affects : See LoadPCXToBitmap.
}




Procedure LocatePCX(filename:string; Var ThePalette: PaletteType;
	  x,y,widthtoshow,heighttoshow:Word);
begin
     LoadPCXToBitmap(filename,
     Ptr(CurrentBitmapSegment,CurrentBitmapOffset),
     ThePalette, x+ViewX, y+ViewY,
     widthtoshow,heighttoshow);



end;













{
What this does is load a PCX at the TOP LEFT of the Current Window,
very quickly. If you need to put the PCX somewhere else use LocatePCX.
Code altered November 16th 1996.


Expects:  FileName to be a standard MS-DOS filename, relating to a
	  PCX which may be of any size. (Only 320 x 200 or smaller
	  PCXs will fit on screen tho' - other sizes are clipped
	  as necessary)
	  ThePalette to be of type Palette. This holds the colour
	  information of the PCX file you are loading.

	  You can then use UsePalette to set the VGA palette so that
	  the pic can display properly.

Returns:  Error code 1 back to parent process if PCX failed to load.

Affects : Probably everything!! :)
}


Procedure LoadPCX(FileName:string; Var ThePalette: PaletteType);
Begin
     LocatePCX(Filename,ThePalette,0,0,ViewWidth,ViewHeight);
End;









{
Save area of any Bitmap to file. Code altered on 15th November 1996.

This is the main routine, and the NEWGRAPH & KOJAKVGA 3.2 versions
had a few omissions that prevented it from saving PCXs that could be
loaded into PaintShop Pro/Dpaint.

It's sorted now tho'!!! (Mind you, you could load the PCX's saved
with the old versions into GWS no problem, then re-save a 'properly'
formatted PCX from there)

I shall state this now: THIS WORKS!!!! :)
I've loaded piccies of various sizes into Photoshop/Dpaint NO PROBLEM.


Expects:    TheBitmap is a Pointer to the bitmap to save as a PCX.
	    If Nil, then the current bitmap is used.

	    FileName is the MS-DOS filespec of the PCX to save.

	    ThePalette is a PaletteType variable, which has been
	    initialised by, for example, the CopyVGAPaletteTo routine.

	    X,Y specify the horizontal and vertical positions of where to
	    begin grabbing the PCX data from.

	    PCXWidth and PCXHeight specify the width & height of the
	    window to grab. Easy eh?


Returns:    Nothing

Affects:    Everything but the (girl?) DS & SS.
}


Procedure SaveBitmapAreaAsPCX(TheBitmap: Pointer; filename:string;
	  ThePalette: PaletteType; x,y, PCXWidth,PCXHeight: Word);


Var f: File;                    { File for writing PCX to }
    ColourMapID : Byte;         { Always holds 12, for the PCX }
    ColourCount : Byte;         { Counts up to number of colours on
				  screen (255) }
    RedValue    : Byte;         { Palette Values of a colour }
    GreenValue  : Byte;
    BlueValue   : Byte;

    LastBitmap  : Pointer;
    SrcBmapOffs : Word;         { Offset into Current Bitmap }
    VerticalCount : Byte;       { Number of scan lines to use }
    LastByte      : Byte;       { The last Byte read from Current Bitmap }
    NewByte       : Byte;       { The current Byte }
    RunLength     : Byte;       { Counter for run length compression }
    ByteCount     : Word;       { Counts up to bytes per scan line }



Begin
     Assign(f,filename);
     Rewrite(f,1);

     With header do
     Begin
	  Manufacturer := 10;
	  Version      := 5;
	  Encoding     :=1;     { Signify PCX RLE encoding
				  And I missed this in v3.1 (ahem) :) }
	  Bits_per_pixel:=8;    { 8 bits = 256 colours }
	  XMin:=0;
	  YMin:=0;

	  if PCXwidth>320 Then PCXwidth:=320;
	  if PCXheight>200 Then PCXheight:=200;

	  XMax:=(PCXWidth-1);
	  YMax:=(PCXHeight-1);
	  Hres:=PCXWidth;
	  Vres:=PCXHeight;

	  Colour_planes:=1;                 { Mode 13h is not planar }
	  Bytes_per_line:=PCXWidth;         { One Byte per pixel }
	  If Odd(PCXWidth) Then
	     Inc(Bytes_per_line);

	  Palette_type:=12;                 { 12 signifies 256 colour
					      palette type }

     End;

     BlockWrite(F,Header,SizeOf(Header));

     { Now initialise the PCX cache, held in RAM, which should
       (hopefully) be 5 x faster than continuous disk writing.
       Isn't this new technique exciting? :)
     }

     InitCache(FileName,IOWrite,MaxAvail);

     LastBitmap:=GetUsedBitmapAddr;
     If TheBitmap <> Nil Then
	UseBitmap(TheBitmap);

     Asm
     MOV AX,X
     MOV BX,Y
     CALL NoWinCalculateOffset          { Want to ignore window settings.. }
     ADD BX,CurrentBitmapOffset          { .. as any bitmap can be saved }
     MOV SrcBmapOffs,BX
     End;

     For VerticalCount:=1 to PCXHeight do
     Begin
	  Asm PUSH SrcBMapOffs End;

	  ByteCount:=0;
	  LastByte:=0;

	  { See NEWGRAPH code for explanation of PCX RLE encoding }

	  Repeat
		NewByte:=Mem[CurrentBitmapSegment:SrcBmapOffs];
		If NewByte = LastByte Then
		   Begin

		   RunLength:=0;
		   While (NewByte = LastByte) and (RunLength < 63)
		      and (ByteCount <> header.bytes_per_line) do
		      Begin
		      Inc(RunLength);
		      Inc(ByteCount);

		      {
		      Move to next Byte on Current Bitmap
		      }

		      Inc(SrcBmapOffs);
		      NewByte:=Mem[CurrentBitmapSegment:SrcBmapOffs];
		   End;

		   { Signal run of bytes }

		   Asm
		   OR Byte Ptr RunLength, 192
		   End;

		   { Note the all-singing, all-dancing TunstallSoft (tm)
		     Disk Caching (Thrashing?) software routines -
		     guaranteed to make you "FORMAT C:" straight away :)
		   }



		   CacheByte(RunLength);
		   CacheByte(LastByte);
		   LastByte:=NewByte;
		   End
		Else
		    If (NewByte > 191) Then
		       Begin
		       Inc(ByteCount);
		       Inc(SrcBmapOffs);                { Point to next Byte on screen }
		       CacheByte(193);
		       CacheByte(NewByte);
		       LastByte:=NewByte;
		       End
		    Else
			Begin
			Inc(ByteCount);
			Inc(SrcBmapOffs);
			CacheByte(NewByte);
			LastByte:=NewByte;
			End;

	  Until ByteCount = header.bytes_per_line;

	  Asm   POP SrcBMapOffs
		ADD SrcBMapOffs,320
	  End;
     End;

     { 12 is colour-map ID. }

     CacheByte(12);

     For ColourCount:=0 to 255 do
	 Begin

	 RedValue:=ThePalette.   RedLevel[ColourCount] SHL 2;
	 GreenValue:=ThePalette. GreenLevel[ColourCount] SHL 2;
	 BlueValue:=ThePalette.  BlueLevel[ColourCount] SHL 2;
	 CacheByte(RedValue);
	 CacheByte(GreenValue);
	 CacheByte(BlueValue);

     End;

     CloseCache;
     UseBitmap(LastBitmap);
End;






{
Save area of Current Bitmap to file. Code altered 15th November 1996.

Expects:    FileName is the name of the PCX to save.
	    ThePalette is a PaletteType variable, which has been
	    initialised by, for example, the CopyVGAPaletteTo routine.

	    X,Y specify the horizontal and vertical positions of where to
	    begin grabbing the PCX data from in the current window.
	    PCXWidth and PCXHeight specify the width & height of the
	    area to grab. Easy eh?

	    For example, to grab one half of the VGA screen you could use:

	    SetWindow(0,0,319,199);
	    SaveAreaAsPCX('1STHALF.PCX',MyPalette,0,0,160,200);

	    And the other half with :

	    SaveAreaAsPCX('2NDHALF.PCX',MyPalette,160,0,160,200);

	    These files can then be loaded into a paint package such
	    as PC Paintbrush or Neopaint (great program!) and manipulated.

	    Use the SAVEPCX routine below to save an entire PCX screen.


Returns:    Nothing

Affects:    YooHoo! It's DS & SS time again.

Notes:      I could MURDER for macros!!

}



Procedure SaveAreaAsPCX(filename:string;ThePalette: PaletteType;
	  x,y, PCXWidth,PCXHeight: Word);
Begin
     inc(x,ViewX);
     inc(y,ViewY);

     If (x+PCXWidth) > EndViewX Then
	PCXWidth:=(EndViewX-x)+1;           { Working with # of bytes,
					  remember! }
     If (y+PCXHeight) > EndViewY Then
	PCXHeight:=(EndViewY-y)+1;

     SaveBitmapAreaAsPCX(Nil, filename,ThePalette, x,y,PCXWidth,PCXHeight);
End;






{
Save the entire Current Bitmap to a PCX file. Code altered 29th October
1996.

Expects  :  Filename is the MS-DOS filespec , i.e. "C:\PICS\MYFILE.PCX"
	    ThePalette specifies a PaletteType record to save to disk in
	    the PCX file.

Returns  :  Nothing

Affects  :  All 286 regs except DS & SS, probably ;)
	    You know what Pascal's like :)
}


Procedure SavePCX(filename:string;ThePalette: PaletteType);
Begin
     SaveBitmapAreaAsPCX(Nil, filename,ThePalette,ViewX,ViewY,
     ViewWidth,ViewHeight);
End;





{
This procedure (which should have been a macro, Borland!) allows you
to save any bitmap as a PCX file, so you don't have to Use it first.
Note: The current window is ignored, and

Expects: TheBitmap is a Pointer to the bitmap to save.
	 Filename is obvious;
	 ThePalette specifies the palette object to save with the
	 PCX file.

Returns: Nothing

Affects: See SavePCX.

Notes  : These routines reduce the amount of typing you do!
	 And in future, when KOJAKVGA is no doubt altered,
	 they'll still work as planned... hopefully!
}



Procedure SaveBitmapAsPCX( TheBitmap: Pointer; filename:string;
			   ThePalette: PaletteType);
Begin
     SaveBitmapAreaAsPCX(TheBitmap,filename,ThePalette,0,0,320,200);
End;














{
====================================================================


FONT ROUTINES - THAT ARE AS OLD AS THE HILLS :)
(STILL no info on Compugraphic/ Truetype or Windows fonts - help!)


--------------------------------------------------------------------
}







{
Select which of the Fonts in ROM you use to write text to the
screen.

Expects : FontNumber can be:

	  0: For CGA Font (Dunno what size it is tho')
	  1: For 8 x 8 Font  ( Standard )
	  2: For 8 x 14 Font ( Prints OK on my ISA CL-5422, but not on my
			       PCI CL-5446. Hmm.. )
	  3: For 8 x 8 Font
	  4: For 8 x 8 Font high 128 characters
	  5: For Rom Alpha Alternate Font
	  6: For 8 x 16 Font
	  7: For Rom Alternate 9 x 16 Font (Doesn't show on mine)


Returns : If you could use the font, this function returns TRUE.

Affects : AX,BX,ES
}


Function UseFont(FontNumber:Byte): boolean; Assembler;
Asm
     MOV AX,$1130                      { Get Font address }
     MOV BH,FontNumber
     CMP BH,7                          { Font number > 7 ? }
     JA @NoWriteSize                   { Yes, so it's invalid }

     PUSH BP                           { Mustn't corrupt BP, as Turbo
					 needs it preserved for local
					 variable access }
     PUSH BX                           { Nor BH as it's to be used later }
     INT $10                           { Now get Font address }
     MOV CurrentFontSegMent,ES         { ES:BP points to where Font is }
     MOV CurrentFontOffset,BP          { located in ROM }
     POP BX                            { Restore Font number }
     POP BP                            { Restore BP }

     CMP BH,Int1fFont                  { User Font in memory ? }
     JZ @NoWriteSize                   { Don't set size, could be more than
					 8 x 8. User will have to set himself.
					 Please correct me if I am wrong }
     CMP BH,StandardVGAFont
     JZ @Set8x8
     CMP BH,Font8x8dd
     JZ @Set8x8
     CMP BH,Font8x8ddHigh
     JZ @Set8x8
     CMP BH,AlphaAlternateFont
     JNZ @Check8x14Font

@Set8x8:
     MOV AL,8                          { Width of 8 }
     MOV AH,8                          { Height of 8 }
     JMP @DoWrite


{ This font was on my Cirrus 5422, but NOT on my C5446 PCI chap.
  So using it may cause "small" (flocking HUGE!) problems.
  Forewarned is forearmed eh?
}

@Check8x14Font:
     CMP BH,Font8x14
     JNZ @Check8x16Font
     MOV AL,8                          { Width 8, Height 14, ByteWidth 1 }
     MOV AH,14
     JMP @DoWrite

@Check8x16Font:
     CMP BH,Font8x16
     JNZ @UseRomAlternateFont
     MOV AL,8                          { Oh C'mon do I have to document }
     MOV AH,16                         { this ? }
     JMP @DoWrite

@UseRomAlternateFont:
     MOV AL,9                          { Never used this one, myself }
     MOV AH,16


@DoWrite:
     MOV CurrentFontWidth,AL           { Write Font details so that }
     MOV CurrentFontHeight,AH          { this Font can be Printed }
     SHR AL,3
     MOV CurrentFontByteWidth,AL

     MUL AH                            { Can only have 255 bytes per char }
     MOV CurrentFontBytesPerChar,AL    { (Should be large enough eh?) }
     MOV AL,True
     JMP @NowExit

@NoWriteSize:
     MOV AL,False

@NowExit:
End;








{
If you wish to do your own text routines, then this returns the
address of the current font.

Expects  : Nothing

Returns  : A Pointer to where the current font is stored.

Affects  : AX,DX.
}


Function GetUsedFontAddr: Pointer; Assembler;
Asm
   MOV DX,CurrentFontSegment
   MOV AX,CurrentFontOffset
End;






{
If you want to use a Font loaded in from disk use SetNewFontAddress to
specify where the new Font resides in memory.

Expects  : NewFontPtr is the address of the font to use.

Returns  : Nothing

Affects  : AX
}

Procedure SetNewFontAddress(NewFontPtr: Pointer); Assembler;
Asm
   MOV AX,WORD PTR NewFontPtr[2]
   MOV CurrentFontSegment,AX
   MOV AX,WORD PTR NewFontPtr
   MOV CurrentFontOffset,AX
End;







{
Find out what width and height the current Font is.

Expects: CurrFontWidth and CurrFontHeight are two uninitialised
	 variables.

Returns: CurrFontWidth and CurrFontHeight on exit hold the width
	 and height of the current Font.

Affects  : AX,DI,ES
}


Procedure GetCurrentFontSize(Var CurrFontWidth, CurrFontHeight:Byte); Assembler;
Asm
   MOV AL,CurrentFontWidth
   MOV AH,CurrentFontHeight

   LES DI,CurrFontWidth         { ES: DI points to variable now }
   MOV [ES:DI],AL
   LES DI,CurrFontHeight
   MOV [ES:DI],AH
End;







{
Specify width and height of a user created Font.

Expects  : NewFontWidth must be above 7
	   NewFontHeight can be any non-zero number.

Returns  : Nothing

Affects  : AX

}

Procedure SetFontSize(NewFontWidth, NewFontHeight:Byte); Assembler;
Asm
     MOV AL,NewFontWidth
     MOV AH,NewFontHeight

     CMP AL,8                   { Width >= 8 ? }
     JB @IllegalSize
     OR AH,AH                   { Is Height 0 ? }
     JZ @IllegalSize

     MOV CurrentFontWidth,AL
     MOV CurrentFontHeight,AH
     SHR AL,3                   { Calculate Byte width of characters
				  i.e. divide width in pixels by 8 }
     MOV CurrentFontByteWidth,AL
     MUL AH
     MOV CurrentFontBytesPerChar,AL
     JMP @ExitNow

@IllegalSize:
     XOR AL,AL
     MOV BYTE PTR CurrentFontWidth,0
     MOV BYTE PTR CurrentFontHeight,0

@ExitNow:
End;







{
For those of you who want to do your own text routines, this
procedure may lighten your workload a bit.

Expects  : Characternumber to be (obviously) the number of the
	   character.

Returns  : This Function returns the offset address of character.

Affects  : AX,BX,DX
}

Function GetFontCharOffset(CharNum:Byte): Word; assembler;
Asm
   MOV AL,CharNum                  { Get number of character into AL }
   MOV BH,CurrentFontByteWidth
   MOV BL,CurrentFontHeight
   MUL BL                          { Multiply character num by FontHeight }
   MOV BL,BH
   XOR BH,BH
   MUL BX                          { And FontWidth }
   ADD AX,CurrentFontOffset        { Now add in the font offset }
End;







(*
I've examined Compugraphic fonts and come to a standstill. So I reckoned
I'd update my GRABIMG utility so I could nick fonts from a PCX!

Watch this space!


This command will load a font into memory and put the information
about the font's size, mem usage etc into the FontRec record.

Expects: FontFileName is the MS-DOS name of the font to load.
	 FontRec is the record used to hold the fonts details.

Returns: FontRec will be filled with data if font loaded OK.
	 If Not, then your program halts and returns an error level
	 of 1 to the parent process.


*)


Procedure LoadFont(FontFileName:String; Var FontRec: FontType);
Var FontFile : File;
    BytesToReserve : Word;
    FontPtr : Pointer;

Begin
     Assign(FontFile,FontFileName);

     {$i-}
     Reset(FontFile,1);
     {$i+}

     If IoResult = 0  Then
	Begin
	BlockRead(FontFile,FontRec,SizeOf(FontRec));
	With FontRec Do
	     Begin
	     BytesToReserve:=FontChars * (FontByteWidth * FontHeight);
	     GetMem(FontPtr,BytesToReserve);
	     Asm
	     LES DI,FontRec
	     MOV AX,WORD PTR FontPtr
	     MOV [ES:DI.FontOfs],AX
	     MOV AX,WORD PTR FontPtr[2]
	     MOV [ES:DI.FontSeg],AX
	     End;

	     BlockRead(FontFile,Mem[FontSeg:FontOfs],BytesToReserve);
	End;
	Close(FontFile);
	End
     Else
	 Begin
	 Writeln('Error: Couldn''t load font file ',FontFileName,'.');
	 Halt(1);
     End;
End;







{
This routine will save a portion (or all) of the current Font to disk.

Expects  : FontFileName to be an MS-DOS filename to hold the char data.
	   FirstChar to be the number of the first character to save (0-255);
	   NumChars to be the number of characters to save (You may only
	   want to save part of a Font).

Returns  : Nothing

Affects  : Don't know.
}


Procedure SaveFont(FontFileName:String; FirstChar, Numchars:Byte);
Var TempFontRec     : FontType;
    FontFile        : File;
    BytesPerChar    : Word;
    FirstCharOffset : Word;

Begin
     With TempFontRec do
	  Begin
	  FontSeg:=0;               { 0 Meaning uninitialised }
	  FontOfs:=0;
	  FontByteWidth:=CurrentFontByteWidth;
	  FontWidth:=CurrentFontWidth;
	  FontHeight:=CurrentFontHeight;
	  FontChars:=NumChars;
     End;

{ Write header first }

     Assign(FontFile,FontFileName);
     Rewrite(FontFile,1);
     BlockWrite(FontFile,TempFontRec,SizeOf(TempFontRec));

{ And now the charmap }

     BytesPerChar:=CurrentFontByteWidth * CurrentFontHeight;
     FirstCharOffset:=CurrentFontOffset+(FirstChar * BytesPerChar);

     BlockWrite(FontFile, Mem[CurrentFontSegment:FirstCharOffset],
     NumChars * BytesPerChar);

     Close(FontFile);

End;








{
Use a Font loaded in from disk.

This routine allows characters of any size, as long as the total of bytes
used to define a character does NOT exceed 255.

Expects  : Variable FontRec to have been initialised (usually by
	   LoadFont). You could initialise FontRec yourself if you
	   liked and that would be faster than using SetNewFontAddress,
	   SetFontSize etc.

Returns  : Nothing

Affects  : As usual, everything except DS & SS.
}


Procedure UseLoadedFont(FontRec : FontType);
Begin
     With FontRec Do
	  Begin
	  CurrentFontSegment:=FontSeg;
	  CurrentFontOffset:=FontOfs;
	  SetFontSize(FontWidth,FontHeight);
     End;
End;







{
DAMN! The last text print routine (called OutTextXY) had a bug
which was a right rotten beggar. It's been sorted here tho' -
I did tell you I didn't have much time to test all my
work did I? (And no chars > 8 pixels to grab? :) )

And yes, I did test this chap - A wee bit!.

Expects  : x,y specify the horizontal, vertical position of text <txt>
	   to print.

Returns  : Nothing

Affects  : AX, BX, CX, DX, SI, DI, ES.

Notes    : Changed PrintXY to PrintAt as it's now a whole new beast
	   from OutTextXY. Graphics cursor is NOT changed.
}




Procedure PrintAt(x,y: Integer; txt:string); Assembler;
Var Chars   : Byte;
    TextSeg : Word;
    Currx   : Word;

Asm
   lES SI,txt
   MOV textseg,ES
   MOV AL,[ES:SI]
   MOV chars,AL
   INC SI

{ Calculate font ofs }

@GetNextChar:
   MOV ES,textseg
   MOV AL, [ES:SI]
   INC SI
   MUL BYTE PTR currentfontbytesperchar

   MOV DI, currentfontoffset
   ADD DI,AX

   MOV ES,currentfontsegment    { The following 4 regs only get re-loaded }
   MOV DL,currentcolour         { after moving to the next character }
   MOV BX,y
   MOV CH,currentfontheight

@downloop:
   MOV CL,currentfontbytewidth  { Used to count across }
   MOV AX,x

@acrossloop:
   MOV DH,8                     { 8 bits in a Byte, remember :) }

   PUSH CX                      { Save currentfontwidth on stack }
   MOV CL,[ES:DI]               { Read Byte from charmap }

@bitsloop:
   TEST CL,$80                  { Bit 7 set ? }
   JZ @noplot                   { Nope, so don't put a pixel }

   PUSH AX                      { Save X & Y coords as CalculateOffset }
   PUSH BX                      { corrupts them (FPutPixel calls it) }
   CALL FPutPixel               { Draw a dot, with colour <DL> }
   POP BX
   POP AX

@noplot:
   SHL CL,1                     { Shift bit from character map }
   INC AX                       { Update X coord }
   DEC DH                       { Reduce bit count }
   JNZ @bitsloop

   INC DI
   POP CX
   DEC CL                       { Dec currentfontwidth by 1 }
   JNZ @acrossloop              { If not all done then keep plotting pixs }
   INC BX                       { Do next row }
   DEC CH

   JNZ @downloop

{ Now update the temporary graphics cursor }

   CLC
   MOV AX,x
   ADD AL,currentfontwidth
   ADC AH,0
   MOV x,AX

{ Reduce character count }

   DEC BYTE PTR chars
   JNZ @getnextchar
End;












{
Display a string of text at the current cursor position, using
the current Font.

Expects  : Txt is the text to write at the current cursor position.

Returns  : Graphics cursor has moved.

Affects  : See PrintAt.
}

Procedure Print(txt:string);
Begin
     PrintAt(CursorX,CursorY,txt);
End;












{
====================================================================


			PALETTE ROUTINES


--------------------------------------------------------------------

}




{
Get the red, green and blue components of a colour.

Expects  :  ColourNumber is the number of the colour of which you
	    want to read the Palette values (0-255).
	    RedValue, GreenValue, BlueValue need not be initialised.

Returns  :  The Red, Green, Blue Values of the colour specified
	    by ColourNumber.

Affects  :  AL, DX, DI, ES
}

Procedure GetRGB(ColourNumber : Byte; VAR RedValue, GreenValue,
	  BlueValue : Byte); Assembler;
Asm
   MOV DX,$3C7          { $3C7 is colour ** READ ** select port. }
   MOV AL,ColourNumber  { Select colour to read }
   OUT DX,AL
   ADD DL,2             { DX now = $3C9, which must be read 3 times
			  in order to obtain the Red, Green and
			  Blue values of a colour }

   IN AL,DX             { Read red amount. Don't use IN AX,DX as
			  for some strange reason it doesn't work ! }
   LES DI,RedValue
   MOV [ES:DI],AL       { (Smarmy comment removed :) ) }
   IN AL,DX             { IN AX,DX doesn't seem to work on my ISA card }
			{ so I left it out for you DX-2 chaps! }

   LES DI,GreenValue
   MOV [ES:DI],AL

   IN AL,DX             { Read blue }
   LES DI,BlueValue
   MOV [ES:DI],AL
End;









{
This will change the red green and blue components of a colour,
thereby affecting it's shade. How's that for picturesque speech ?

Note : You don't need a PaletteType record to use this command,
it affects the screen directly.

Expects  : ColourNumber is the number of the colour from 0 to 255.
	   RedValue is the red component of the colour (0-63).
	   GreenValue is the green component of the colour (0-63).
	   BlueValue is the blue component of the colour (0-63).

Returns  : Nothing

Affects  : AL,DX
}


Procedure SetRGB(ColourNumber, RedValue, GreenValue,
	  BlueValue : Byte); Assembler;
Asm
   MOV AL,ColourNumber
   MOV DX,$3c8          { Write to Port $3C8 with number of Colour to alter }
   OUT DX,AL
   INC DL               { $3C9 used to write colour RGB data }
   MOV AL,RedValue      { Store Red }
   OUT DX,AL
   MOV AL,GreenValue    { Store Green }
   OUT DX,AL
   MOV AL,BlueValue     { Store Blue }
   OUT DX,AL
End;







(*
This Procedure takes a snapshot of all of the VGA colour palette
used.

Expects : Palette is a variable of type PaletteType which will
	  hold the 256 colour palette.

Returns : <Palette> should now contain the VGA colour palette.

Affects : AL, BX, CX, DX, SI, DI

Notes   : Use this command just before a mode change so that
	  you can restore the palette to it's original state
	  (via UsePalette) at the end of the program.

*)


Procedure CopyVGAPaletteTo(Var Palette : PaletteType); Assembler;
Asm
   PUSH DS
   LDS BX, Palette      { DS:BX points to Palette record }
   XOR AL,AL            { Let's start with colour 0 }
   MOV DX,$3c7          { Check out the cut & pasting from UsePalette :)
			  $3c7 selects the first colour to read.
			  After 3 reads from $3c9, the VGA automatically
			  moves to the next Colour so there is no
			  need to write to $3c7 again. }
   OUT DX,AL
   INC DL
   INC DL               { Make DX = $3c9, which is used to read the
			   Red / Green and Blue values of a Colour }
   MOV CX,MaxColours    { 256 colours }
   MOV SI,BX
   ADD SI,CX            { Make SI point to green levels }
   MOV DI,SI
   ADD DI,CX            { Make DI point to blue levels }


@ReadPaletteInfo:
   IN  AL,DX            { Read red level from VGA }
   MOV [BX],AL          { Write it to Palette struct }
   IN  AL,DX            { Read green level }
   MOV [SI],AL
   IN  AL,DX            { And blue }
   MOV [DI],AL
   INC DI               { Next Red part of record }
   INC BX               { Next Green }
   INC SI               { Next Blue }
   DEC CX
   JNZ @ReadPaletteInfo
   POP DS
End;









{
Do I need to explain what this does? It loads in a Palette
from file FileName and stores it in the variable Palette.
Easy enough to use.

Expects  : FileName is standard MS-DOS filename which refers to the
	   palette file.
	   Palette is variable of type PaletteType used to hold
	   the palette data.

Returns  : Palette should contain the data read from palette file.

Affects  : Don't know. Probably everything except DS & SS.
}


Procedure LoadPalette(FileName: String; Var Palette : PaletteType);
Var PaletteFile: File;
Begin
     Assign(PaletteFile,FileName);
     {$i-}
     Reset(PaletteFile,1);
     {$i+}
     If IoResult = 0 Then
	Begin
	BlockRead(PaletteFile,Palette,SizeOf(Palette));
	Close(PaletteFile);
	End
     Else
	 Begin
	 Writeln('Error: Couldn''t load palette file ',FileName,'.');
	 Halt(1);
     End;
End;







{
Guess what this does then !.

Expects  : FileName is the MS-DOS file spec of the palette to be saved.
	   Palette is the palette to be saved.

Returns  : Nothing

Affects  : The whole damn shebang! Except DS & SS.
}


Procedure SavePalette(FileName: String; Palette : PaletteType);
Var PaletteFile: File;
Begin
     Assign(PaletteFile,FileName);
     Rewrite(PaletteFile,1);
     BlockWrite(PaletteFile,Palette,SizeOf(Palette));
     Close(PaletteFile);
End;










{
This sets the DACs to the Colours specified in your
Palette array. Do NOT alter the Palette data structure
or else this won't work.

Expects  : Palette is an initialised palette of PaletteType.

Returns  : Nothing

Affects  : AL, BX, CX (It was CL before), DX, SI, DI, ES

Notes    : As OUT DX,AX may not work with some graphics
	   cards (like my old Cirrus 5422) I decided to
	   stick with the 8-bit version. Yeeha!

}


Procedure UsePalette(Palette : PaletteType); Assembler;
Asm
   PUSH DS
   LDS BX, Palette      { DS:BX points to Palette record }
   XOR AL,AL
   MOV DX,$3c8          { $3c8 selects the first colour to alter.
			  After 3 writes to $3c9, the VGA automatically
			  moves to the next Colour so there is no
			  need to write to $3c8 again. }
   OUT DX,AL
   INC DL               { Make DX = $3c9, which is used to set the
			   Red / Green and Blue values of a Colour }
   MOV CX,MaxColours    { 256 colours }
   MOV SI,BX
   ADD SI,CX            { Make SI point to green levels }
   MOV DI,SI
   ADD DI,CX            { Make DI point to blue levels }


@WritePaletteInfo:
   MOV AL, [BX]         { Read red level from Palette struct }
   OUT DX,AL            { Write to port $3c9 }
   MOV AL, [SI]         { Read green level from Palette struct }
   OUT DX,AL            { Write to port $3c9 }
   MOV AL, [DI]         { Read blue level from Palette struct }
   OUT DX,AL            { Write to port $3c9 }
   INC DI               { Next Red part of record }
   INC BX               { Next Green }
   INC SI               { Next Blue }
   DEC CX
   JNZ @WritePaletteInfo
   POP DS
End;






{
Set the new graphics colour. Also affects text routines as well.

Expects  : NewColour is the new graphics Colour.

Returns  : Nothing.

Affects  : AL.
}


Procedure UseColour(NewColour:Byte); Assembler;
Asm
    MOV AL,NewColour
    MOV CurrentColour,AL
End;






{
Get the current graphics colour.

Expects  : Nothing

Returns  : GetColour = Current graphics colour

Affects  : My mind when I document one liner pieces of crap (code)
	   like this :)
}

Function GetColour: Byte; Assembler;
Asm
     MOV AL, CurrentColour;
End;
















{
====================================================================


		     MISCELLANEOUS ROUTINES


--------------------------------------------------------------------
}







{
Wait for a certain number of vertical retraces, specified by
the number in TimeOut.

Expects : TimeOut is the number of vertical retraces you want to wait
	  for.

Returns : Nothing.

Notes   : The NEWGRAPH Vwait function didn't work properly. This new
	  version does work, because I nicked the code from somewhere
	  else and modified it slightly.


Affects : AL,CX,DX

}


Procedure Vwait(TimeOut:Word); Assembler;
Asm
   MOV CX,TimeOut         { CX = Number of times to wait }
   MOV DX,$03DA

@WaitRetraceEnd:

   IN  AL,DX              { Wait until the current retrace
			    has finished (if one is in progress) }
   TEST AL,$08
   JZ @WaitRetraceEnd

@WaitRetraceStart:        { Then wait until a retrace starts }
   IN  AL,DX
   TEST AL,$08
   JNZ @WaitRetraceStart

   DEC CX
   JNZ @WaitRetraceEnd

End;











(*
Return the version number of the current KOJAKVGA unit.
This function is NOT present in NEWGRAPH (Predecessor to KOJAKVGA,
you can check it out in June 96's GRAPHICS.SWG)

Expects:  Nothing

Returns:  GetVersion = Current Version of KOJAKVGA.
	  AH = Major version number
	  AL = Minor version number

	  ex: KOJAKVGA 3.2 returns AH = 3. AL = 2

Affects : AX
*)


Function GetVersion: Word; Assembler;
Asm
   MOV AX,KOJAKVGAVersion
End;










{
====================================================================


		      INITIALISATION SECTION


--------------------------------------------------------------------

}




Begin
     { Bitmap stuff first }

     InitOffsets;
     UseBitmap(VGA_ADDR);            { All draw ops default to VGA screen }
     Cls;                            { Flush video mem }

     { Then window stuff }

     SetWindow(0,0,319,199);         { Window set to full screen }
     MoveTo(0,0);                    { Graphics Cursor to top left }
     UseColour(1);                   { Use Colour 1 }
     UseFont(StandardVGAFont);       { standard 8 x 8 }

     Write('KOJAKVGA (486 enhanced) version ');
     Write(GetVersion DIV 256,'.',GetVersion AND $FF);
     Writeln(' (C) 1996,1997 Scott Tunstall.');
     Writeln('This unit is FREEWARE. Please distribute source/compiled code');
     Writeln('freely in it''s original, unaltered state.');
     Writeln;
End.



{ See that bloke Geoff Bassett: Inverkeithing's Diamond Geezer! ;) }

