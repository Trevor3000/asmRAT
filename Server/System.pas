unit System;

interface

procedure _HandleFinally;

type

TGUID = record

D1: LongWord;

D2: Word;

D3: Word;

D4: array [0..7] of Byte;

end;

PInitContext = ^TInitContext;

TInitContext = record

OuterContext: PInitContext; 

ExcFrame: Pointer; 

InitTable: pointer; 

InitCount: Integer; 

Module: pointer; 

DLLSaveEBP: Pointer; 

DLLSaveEBX: Pointer; 

DLLSaveESI: Pointer; 

DLLSaveEDI: Pointer; 

ExitProcessTLS: procedure; 

DLLInitState: Byte; 

end;                              

procedure _ROUND;
procedure       _TRUNC;
function Get8087CW: Word;
procedure Set8087CW(NewCW: Word);
procedure       Move( const Source; var Dest; count : Integer );
procedure __lldiv;
var
  Default8087CW: Word = $1332;

implementation

procedure __lldiv;
asm
        push    ebp
        push    ebx
        push    esi
        push    edi
        xor     edi,edi

        mov     ebx,20[esp]             // get the divisor low dword
        mov     ecx,24[esp]             // get the divisor high dword

        or      ecx,ecx
        jnz     @__lldiv@slow_ldiv      // both high words are zero

        or      edx,edx
        jz      @__lldiv@quick_ldiv

        or      ebx,ebx
        jz      @__lldiv@quick_ldiv     // if ecx:ebx == 0 force a zero divide
          // we don't expect this to actually
          // work

@__lldiv@slow_ldiv:

//
//               Signed division should be done.  Convert negative
//               values to positive and do an unsigned division.
//               Store the sign value in the next higher bit of
//               di (test mask of 4).  Thus when we are done, testing
//               that bit will determine the sign of the result.
//
        or      edx,edx                 // test sign of dividend
        jns     @__lldiv@onepos
        neg     edx
        neg     eax
        sbb     edx,0                   // negate dividend
        or      edi,1

@__lldiv@onepos:
        or      ecx,ecx                 // test sign of divisor
        jns     @__lldiv@positive
        neg     ecx
        neg     ebx
        sbb     ecx,0                   // negate divisor
        xor edi,1

@__lldiv@positive:
        mov     ebp,ecx
        mov     ecx,64                  // shift counter
        push    edi                     // save the flags
//
//       Now the stack looks something like this:
//
//               24[esp]: divisor (high dword)
//               20[esp]: divisor (low dword)
//               16[esp]: return EIP
//               12[esp]: previous EBP
//                8[esp]: previous EBX
//                4[esp]: previous ESI
//                 [esp]: previous EDI
//
        xor     edi,edi                 // fake a 64 bit dividend
        xor     esi,esi

@__lldiv@xloop:
        shl     eax,1                   // shift dividend left one bit
        rcl     edx,1
        rcl     esi,1
        rcl     edi,1
        cmp     edi,ebp                 // dividend larger?
        jb      @__lldiv@nosub
        ja      @__lldiv@subtract
        cmp     esi,ebx                 // maybe
        jb      @__lldiv@nosub

@__lldiv@subtract:
        sub     esi,ebx
        sbb     edi,ebp                 // subtract the divisor
        inc     eax                     // build quotient

@__lldiv@nosub:
        loop    @__lldiv@xloop
//
//       When done with the loop the four registers values' look like:
//
//       |     edi    |    esi     |    edx     |    eax     |
//       |        remainder        |         quotient        |
//
        pop     ebx                     // get control bits
        test    ebx,1                   // needs negative
        jz      @__lldiv@finish
        neg     edx
        neg     eax
        sbb     edx,0                   // negate

@__lldiv@finish:
        pop     edi
        pop     esi
        pop     ebx
        pop     ebp
        ret     8

@__lldiv@quick_ldiv:
        div     ebx                     // unsigned divide
        xor     edx,edx
        jmp     @__lldiv@finish
end;

procedure       Move( const Source; var Dest; count : Integer );
{$IFDEF PUREPASCAL}
var
  S, D: PChar;
  I: Integer;
begin
  S := PChar(@Source);
  D := PChar(@Dest);
  if S = D then Exit;
  if Cardinal(D) > Cardinal(S) then
    for I := count-1 downto 0 do
      D[I] := S[I]
  else
    for I := 0 to count-1 do
      D[I] := S[I];
end;
{$ELSE}
asm
{     ->EAX     Pointer to source       }
{       EDX     Pointer to destination  }
{       ECX     Count                   }

        PUSH    ESI
        PUSH    EDI

        MOV     ESI,EAX
        MOV     EDI,EDX

        MOV     EAX,ECX

        CMP     EDI,ESI
        JA      @@down
        JE      @@exit

        SAR     ECX,2           { copy count DIV 4 dwords       }
        JS      @@exit

        REP     MOVSD

        MOV     ECX,EAX
        AND     ECX,03H
        REP     MOVSB           { copy count MOD 4 bytes        }
        JMP     @@exit

@@down:
        LEA     ESI,[ESI+ECX-4] { point ESI to last dword of source     }
        LEA     EDI,[EDI+ECX-4] { point EDI to last dword of dest       }

        SAR     ECX,2           { copy count DIV 4 dwords       }
        JS      @@exit
        STD
        REP     MOVSD

        MOV     ECX,EAX
        AND     ECX,03H         { copy count MOD 4 bytes        }
        ADD     ESI,4-1         { point to last byte of rest    }
        ADD     EDI,4-1
        REP     MOVSB
        CLD
@@exit:
        POP     EDI
        POP     ESI
end;
{$ENDIF}

procedure Set8087CW(NewCW: Word);
begin
  Default8087CW := NewCW;
  asm
        FNCLEX  // don't raise pending exceptions enabled by the new flags
{$IFDEF PIC}
        MOV     EAX,[EBX].OFFSET Default8087CW
        FLDCW   [EAX]
{$ELSE}
        FLDCW   Default8087CW
{$ENDIF}
  end;
end;

procedure       _ROUND;
asm
        { ->    FST(0)  Extended argument       }
        { <-    EDX:EAX Result                  }

        SUB     ESP,8
        FISTP   qword ptr [ESP]
        FWAIT
        POP     EAX
        POP     EDX
end;
procedure       _TRUNC;
asm
       { ->    FST(0)   Extended argument       }
       { <-    EDX:EAX  Result                  }

        SUB     ESP,12
        FNSTCW  [ESP].Word          // save
        FNSTCW  [ESP+2].Word        // scratch
        FWAIT
        OR      [ESP+2].Word, $0F00  // trunc toward zero, full precision
        FLDCW   [ESP+2].Word
        FISTP   qword ptr [ESP+4]
        FWAIT
        FLDCW   [ESP].Word
        POP     ECX
        POP     EAX
        POP     EDX
end;
function Get8087CW: Word;
asm
        PUSH    0
        FNSTCW  [ESP].Word
        POP     EAX
end;
procedure _HandleFinally;
asm
end;

end.

