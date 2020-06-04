{
========================================================================

  FILENAME : PCXCACH2.PAS (VERSION 2)

  AUTHOR   : SCOTT TUNSTALL B.Sc

  CREATION : 24TH NOVEMBER 1996 (v1)
  DATE       18 AUGUST 1997 (v2)

  TESTING  : COMPILED WITH TP7, TESTED WITH P133/ 24MB RAM/ 3GB HD.
  INFO

  PURPOSE  : THIS UNIT SIMPLIFIES THE PCX LOAD AND SAVE ROUTINES FOR
             KOJAKVGA 3.4 ( Which will probably be abandoned due to
             me getting a life ;) )


  NOTES    : THE UNIT ABSTRACTS THE METHODS REQUIRED TO ALLOCATE
             AND ACCESS A MEMORY CACHE.


             IMPORTANT!!!
             THIS UNIT CAN BE USED WITH * ANY * FILE TYPE, NOT JUST PCX.


  DISCLAIMER : USE THIS UNIT AT YOUR OWN RISK.
               I DO NOT GUARANTEE THAT THIS UNIT CODE WILL WORK
               PROPERLY (ALTHOUGH IT APPEARS TO WORK OK ON MY
               PC) OR EVEN THAT IT WILL COMPILE ON YOUR SYSTEM.

               FURTHERMORE, I TAKE NO RESPONSIBILITY FOR ANY DAMAGE
               CAUSED TO YOUR PC HARDWARE OR FILES CAUSED BY
               THE ROUTINES CONTAINED HERE OR WITH ASSOCIATED
               PROGRAMS.


               YOU MAY MODIFY THIS CODE. POST UPDATES TO THE SWAG.

------------------------------------------------------------------------
}








Unit PCXCach2;


{$X+}

Interface

type IOModes = (IOReadNow, IOReadLater, IOWrite, IOAppend);


Function InitCache(FileName: string; IOMode: IOModes;
         CacheSizeReq: word) : longint;
Function GetCacheFileSize: Longint;
Function CacheSeek (TheOffset : Longint) : boolean;
Procedure CacheByte(TheByte: Byte);
Procedure CacheWord(TheWord: Word);
Procedure CacheLong(TheLong: Longint);
Function GetStructFromCache (Var TheStruct; NumBytes: word): boolean;
Function GetByte (Var TheByte : Byte) : boolean;
Function GetWord (Var TheWord: Word)  : boolean;
Function GetLong (Var TheLong: Longint) : boolean;

Function CloseCache: boolean;
Function GetVersion: word;






Implementation





Const PCXCACHEVERSION=$200;

      BIGGEST_CACHE_AVAIL = 0;

      NO_CACHE_OPENED=0;
      IO_NOREAD = -1;
      IO_NOWRITE = -2;
      IO_NOAPPEND = -3;
      MEM_NOT1KLEFT = -4;
      MEM_MALLOCFAIL = -5;



Var   CacheFile       : File;           { File being read/written to }
      CacheFileLength : longint;        { Size of file (in bytes) }
      CacheMode       : IOModes;        { Read/Write cache ? }
      CacheSize       : word;           { Size (in bytes) of cache }
      CacheLimit      : word;           { At start, will be same as
                                          CacheSize, but when EOF
                                          approaches, CacheLimit will
                                          be reduced dramatically to
                                          show cache cannot be
                                          completely filled. }
      CachePosition        : word;           { Number of bytes written }
      CacheSeg        : word;           { Segment of cache }
      CacheOffs       : word;           { Offset of cache }
      CacheReloadOffs : word;           { Used to reload CacheOffs }




Function LoadFileToCache : boolean; Forward;





Procedure ReportError(OpStr: string; Problem_type: integer);
Begin
{$IFDEF SHOWERRORMESSAGE}

     Writeln;
     Writeln( 'ReportError called with error number ',
              Problem_Type,
              ': Error in data '+OpStr+'.');
{$ENDIF}

     { Halt(Problem_Type); }
End;






{
*************************************************************************

Initialise a cache in memory and associate it with a file on disk.

Expects: ** FileName is the file which will be read/written to. **
         It's in MSDOS 8.3 format.

         DO NOT CONFUSE THIS FILE WITH A TEMPORARY STORE ON DISK!
         THE CACHE IS IN MEMORY!!!


         IOMode is the operation you are using the cache for.

---------------------------------------------------------------------

         POSSIBLE IOMODE VALUES
         ----------------------
         IOReadNow     : Initialise the cache for reading from
                         file, then fill it with data immediately
                         (this is recommended)

         IOReadLater   : Initialise the cache for reading from file,
                         but do not fill it with data yet.
                         (Use the CacheSeek or GetXXXX commands to
                         force a data read)

         IOWrite       : Open the cache for writing. Any file
                         with name FileName will be overwritten.


         IOAppend      : Open the cache for appending data to a file
                         that already exists.

---------------------------------------------------------------------



         CacheSizeReq is the cache size (in bytes) wanted. Pass in
         BIGGEST_CACHE_AVAIL (0) to let the system worry about the
         cache size itself.


Returns: The size of the cache allocated, in bytes. 65528 bytes
         is the maximum value that can be returned (yep, blame
         those DOS segments).

         So why am I returning a longint when a word will do? Well,
         if InitCache returns a value 0 or less an error occurred.

         The error will be one of the following:

         IO_NOREAD   : Could not open the file for reading. (In
                       other words the file doesn't exist)

         IO_NOWRITE  : Could not open the file for writing (most
                       likely caused by a share error)

         IO_NOAPPEND : Could not open the file for append (caused
                       by either a share error or - more common- the
                       file specified doesn't exist.

         MEM_NOT1KLEFT : Very serious error.
                        Even though you let the cache system
                        set it's own size value, the largest memory
                        block available on the heap was less than 1K
                        in size and so using the cache would be
                        pointless.

         MEM_MALLOCFAIL : The size of cache requested in CacheSizeReq
                         was bigger than the largest available
                         memory block on the heap.




}








Function InitCache( FileName: string; IOMode: IOModes;
                    CacheSizeReq : word) : longint;

Var CachePtr: Pointer;
Begin
     { Silly values aren't accepted }

     If (FileName='') Or (CacheSizeReq < 1024) Then
     Begin
        InitCache:=NO_CACHE_OPENED;
        Exit;
     End;


     Assign(CacheFile,FileName);


     Case IOMode Of
     IOReadNow,
     IOReadLater : Begin
              {$i-}
              Reset(CacheFile,1);
              {$I+}
              If IoResult <>0 Then
                 Begin
                 ReportError('Error in open (read).', IO_NOREAD);
                 InitCache:=IO_NOREAD;
                 Exit;
                 End;


              CacheFileLength:=FileSize(CacheFile);


              { If IOMode is IOReadNow the user wants the cache to
                contain data NOW }

              End;

     IOWrite: Begin
              {$i-}
              Rewrite(CacheFile,1);
              {$i+}


              If IOResult <>0 Then
                 Begin
                 ReportError('Error in open (write).', IO_NOWRITE);
                 InitCache:=IO_NOWRITE;
                 Exit;
                 End;


              End;

     IOAppend: Begin
               {$i-}
               Rewrite(CacheFile,1);
               Seek(CacheFile,FileSize(CacheFile));
               {$i+}

               { Any errors? }

               If IOResult <>0 Then
                  Begin
                  ReportError('Error in open (append).', IO_NOAPPEND);
                  InitCache:=IO_NOAPPEND;
                  Exit;
                  End;

               End;
     End;

     CacheMode:=IOMode;

     If CacheSizeReq = BIGGEST_CACHE_AVAIL Then
        Begin
        CacheSize:=MaxAvail;
        If CacheSize < 1024 Then
           Begin
           ReportError('Not even 1K of cache left.', MEM_NOT1KLEFT);
           InitCache:=MEM_NOT1KLEFT;
           Exit;
           End
        Else
            GetMem(CachePtr, CacheSize);
        End
     Else

{ User has specified size of cache he wants }


         Begin
         If CacheSizeReq <= MaxAvail Then
            Begin
            CacheSize:=CacheSizeReq;
            GetMem(CachePtr,CacheSize);
            End
         Else
             Begin
             ReportError('CacheSizeReq value too large.' ,
             MEM_MALLOCFAIL);
             InitCache:=MEM_MALLOCFAIL;
             End;
         End;


    Asm
    LES DI, CachePtr
    MOV CacheSeg,ES
    MOV CacheOffs,DI
    MOV CacheReloadOffs,DI
    End;

    CacheLimit:=CacheSize;


    If IOMode = IOReadNow Then
       LoadFileToCache;


    InitCache:=CacheSize;
End;





Procedure SaveCacheToFile;
Begin
     If CachePosition <>0 Then
     Begin
        BlockWrite(CacheFile,Ptr(CacheSeg,CacheOffs)^,CachePosition);
        CachePosition:=0;
        CacheOffs:=CacheReloadOffs;
     End;
End;






{ Write a byte to the cache - straightforward enough.

  Expects : Guess!

  Returns : Nothing

  Notes   : Don't worry about exceeding the cache limits - the system
            handles that contingency for you.

}


Procedure CacheByte(TheByte: Byte);
Begin
     Mem[CacheSeg:CacheOffs]:=TheByte;
     Inc(CacheOffs);
     Inc(CachePosition);
     If CachePosition = CacheSize Then
        SaveCacheToFile;
End;




{ Write a word to the cache. Worth documenting ? }

Procedure CacheWord(TheWord: Word);
Begin
     { Do we have enough room in the cache for a word ? }

     If (CacheSize-CachePosition)>1 Then { yup }
        Begin
        Memw[CacheSeg:CacheOffs]:=TheWord;

        { Point cache offset to next word }

        Inc(CacheOffs,2);
        Inc(CachePosition,2);
        If CachePosition = CacheSize Then
           SaveCacheToFile;
        End
     Else
         { Write data in cache to file then store word }


         Begin
         SaveCacheToFile;       { Dump data in cache to file }
         CacheWord(TheWord);    { We know we can write data now }
         End;
End;





Procedure CacheLong(TheLong: LongInt);
Begin
     { enough room in cache for longint ? }

     If (CacheSize-CachePosition)>3 Then
        Begin
        MemL[CacheSeg:CacheOffs]:=TheLong;

        { Point cache offset to next longint }

        Inc(CacheOffs,4);
        Inc(CachePosition,4);
        If CachePosition = CacheSize Then
           SaveCacheToFile;
        End
     Else
         { Write data in cache to file then store longint }

         Begin
         SaveCacheToFile;
         CacheLong(TheLong);    { We know we can write data now }
         End;
End;






Function LoadFileToCache : boolean;
Var BytesLeft: Longint;
Begin
     BytesLeft:=CacheFileLength-FilePos(CacheFile);

     If BytesLeft > CacheSize Then
        Begin
        CachePosition:=0;                { Reset read bytes count to 0 }
        CacheOffs:=CacheReloadOffs; { Point to start of cache }

        BlockRead(CacheFile,Ptr(CacheSeg,Cacheoffs)^,CacheSize);
        CacheLimit:=CacheSize;
        LoadFileToCache:=True;
        End
     Else
         If BytesLeft > 0 Then
            Begin
            CachePosition:=0;
            CacheOffs:=CacheReloadOffs;
            BlockRead(CacheFile,Ptr(CacheSeg,Cacheoffs)^,BytesLeft);

            { Shrink the cache limit so that unfilled parts of the
              cache can't be read by GetByte, GetWord etc. }

            CacheLimit:=BytesLeft;
            LoadFileToCache:=True;
            End
         Else
             LoadFileToCache:=False;
End;






{ Get the length (in bytes) of the file associated with the cache }

Function GetCacheFileSize: Longint;
begin
     GetCacheFileSize:=Filesize(CacheFile)
End;





{
Move to a specified position within the file associated with the cache;
(A la SEEK in Pascal)

The cache is updated.


Expects: TheOffset specifies the offset into the file associated with
         the cache.

         DO NOT USE THIS COMMAND IF YOU ARE USING THE CACHE IN
         IOWRITE OR IOAPPEND MODE.

Returns: If the seek was successful, TRUE.


}




Function CacheSeek(TheOffset: Longint): boolean;
Begin
     If (TheOffset > CacheFileLength) Then
        CacheSeek:=False
     Else
         Begin
         Seek(CacheFile,TheOffset);
         LoadFileToCache;
         CacheSeek:=True;
         End;
End;






{ Read from the current position in cache to populate
  a data structure.


  Expects: TheStruct is the structure (any type) to populate.
           You can use a pointer reference to copy data from
           the cache to other parts of memory.

           NumBytes is the number of bytes to copy. Usually,
           you'd pass SizeOf(TheStruct).

  Returns: If the number of bytes to be moved is larger than
           the actual cache can handle, then GetStructFromCache
           returns FALSE.

}


Function GetStructFromCache (Var TheStruct; NumBytes: word): boolean;
Begin
     If NumBytes > CacheSize Then
        GetStructFromCache:=False
     Else
         Begin
         { If not all the struct is stored in the cache,
           we now move all of the struct into the cache,
           right at the start! }

         If (CacheSize-CachePosition)<NumBytes Then
            CacheSeek(FilePos(CacheFile));

         Move(Ptr(CacheSeg,CacheOffs)^,TheStruct,NumBytes);
         Inc(CacheOffs,NumBytes);
         Inc(CachePosition,NumBytes);
         GetStructFromCache:=True;
     End;
End;






{
Read a single byte from the cache, and bump the cache ptr to the
next byte contained within the cache (so subsequent calls to
GetByte never read the same byte twice).

Expects: TheByte will be used to contain the byte read from cache.

Returns: If a byte could be read, then GetByte returns TRUE.
         In this case, TheByte contains the byte read.


Notes:   When you call GetByte, the "read position" within the
         cache is updated to point to the next byte.

         If you come to the end of the memory cache, more data will
         be read from file into the cache (unless there is no more
         data to be read from the file - GetByte will return FALSE)

}


Function GetByte (Var TheByte : Byte) : boolean;
Begin
     If CachePosition < CacheLimit Then
        Begin
        TheByte:=Mem[CacheSeg: CacheOffs];
        Inc(CacheOffs);
        Inc(CachePosition);
        GetByte:=True;
        End
     Else
     Begin
         If LoadFileToCache Then
         Begin
              TheByte:=Mem[CacheSeg: CacheOffs];
              Inc(CacheOffs);
              Inc(CachePosition);
              GetByte:=True;
         End
         Else
             GetByte:=False;
     End;
End;





{
Read a single word from the cache, and bump the cache ptr to the
next word contained in the cache.

Expects: TheWord will be used to contain the word read from cache.

Returns: If a word could be read, then GetWord returns TRUE.
         In this case, TheWord contains the word read.


Notes:   When you call GetWord, the "read position" within the
         cache is updated to point to the next word.

         If you come to the end of the memory cache, more data will
         be read from file into the cache (unless there is no more
         data to be read from the file - GetWord will return FALSE)
}





Function GetWord (Var TheWord: Word)  : boolean;
Begin
     If (CacheLimit-CachePosition)>1 Then
        Begin
        TheWord:=MemW[CacheSeg: CacheOffs];
        Inc(CacheOffs,2);
        Inc(CachePosition,2);
        GetWord:=True;
        End
     Else
     Begin
         If LoadFileToCache Then
         Begin
              TheWord:=MemW[CacheSeg: CacheOffs];
              Inc(CacheOffs,2);
              Inc(CachePosition,2);
              GetWord:=True;
         End
         Else
             GetWord:=False;
     End;
End;






{
Read a long integer from the cache, and bump the cache ptr to the
next longint contained in the cache.

Expects: TheLong will be used to contain the longint read from cache.

Returns: If a longint could be read, then GetLong returns TRUE.
         In this case, TheLong contains the LongInt read.


Notes:   When you call GetLong, the "read position" within the
         cache is updated to point to the next longint.

         As with the other 2 GetXXXX functions,
         If you come to the end of the memory cache, more data will
         be read from file into the cache (unless there is no more
         data to be read from the file - GetLong will return FALSE)
}




Function GetLong (Var TheLong: Longint) : boolean;
Begin
     If (CacheLimit-CachePosition)>1 Then
        Begin
        TheLong:=MemL[CacheSeg: CacheOffs];
        Inc(CacheOffs,4);
        Inc(CachePosition,4);
        GetLong:=True;
        End
     Else
     Begin
         If LoadFileToCache Then
         Begin
              TheLong:=MemL[CacheSeg: CacheOffs];
              Inc(CacheOffs,4);
              Inc(CachePosition,4);
              GetLong:=True;
         End
         Else
             GetLong:=False;
     End;
End;







{
When you have finished with the cache, call this function.


Expects: Nothing

Returns: If the cache was successfully created with InitCache
         beforehand, this returns TRUE.


}



Function CloseCache: boolean;
Begin
     if CacheSeg <>0 Then
        Begin
        Case CacheMode Of
        IOWrite,
        IOAppend: If CachePosition <>0 Then
                     Begin
                     SaveCacheToFile;
                     CloseCache:=True;
                     End;

        End;

        FreeMem(Ptr(CacheSeg,CacheReloadOffs),CacheSize);
        Close(CacheFile);

        CacheSeg:=0;
        CacheFileLength:=0;

        CloseCache:=TRUE;
        End
     Else
         CloseCache:=FALSE;

End;






{ So you can check version capabilities }

Function GetVersion:word; Assembler;
Asm
   MOV AX,PCXCacheVersion
End;







{ Announce PCXCache routine. }

Begin
     CacheSeg:=0;
     CacheFileLength:=0;

     Writeln;
     Writeln('PCX-Cache routines for KOJAKVGA 3.xx units (C) 1997 Scott Tunstall.');
     Writeln('Version ',GetVersion DIV 256,'.',GetVersion MOD 256);
     Writeln('This unit is FREEWARE. Please distribute source/compiled code');
     Writeln('freely in it''s original, unaltered state.');
     Writeln;
End.


{
        "Staying out for the summer! Playing games in the rain..."

        This may be my last TP7 program folks... nope, no Delphi either.

        So, this might be goodbye!

        Regards,

             Scott.
}