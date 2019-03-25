unit GR32_Gamma;

interface

uses
  GR32;

{ Gamma bias for line/pixel antialiasing }

type
  TGammaTable8Bit = array [Byte] of Byte;

var
  GAMMA_VALUE: Double;
  GAMMA_TABLE: TGammaTable8Bit;
  GAMMA_INV_TABLE: TGammaTable8Bit;

const
  DEFAULT_GAMMA: Double = 1.6;

// set gamma
procedure SetGamma; overload; // (default)
procedure SetGamma(Gamma: Double); overload; // (default)
procedure SetGamma(Gamma: Double; GammaTable: TGammaTable8Bit); overload;

// apply gamma
function ApplyGamma(Color: TColor32): TColor32; overload;
function ApplyInvGamma(Color: TColor32): TColor32; overload;
function ApplyCustomGamma(Color: TColor32; GammaTable: TGammaTable8Bit): TColor32; overload;

procedure ApplyGamma(Color: PColor32Array; Length: Integer); overload;
procedure ApplyInvGamma(Color: PColor32Array; Length: Integer); overload;
procedure ApplyCustomGamma(Color: PColor32Array; Length: Integer; GammaTable: TGammaTable8Bit); overload;

procedure ApplyGamma(Bitmap: TBitmap32); overload;
procedure ApplyInvGamma(Bitmap: TBitmap32); overload;
procedure ApplyCustomGamma(Bitmap: TBitmap32; GammaTable: TGammaTable8Bit); overload;
procedure ApplyCustomGamma(Bitmap: TBitmap32; Gamma: Double); overload;

implementation

uses
  Math;

function ApplyGamma(Color: TColor32): TColor32;
var
  C: TColor32Entry absolute Color;
  R: TColor32Entry absolute Result;
begin
  C.R := GAMMA_TABLE[C.R];
  C.G := GAMMA_TABLE[C.G];
  C.B := GAMMA_TABLE[C.B];
end;

function ApplyInvGamma(Color: TColor32): TColor32;
var
  C: TColor32Entry absolute Color;
  R: TColor32Entry absolute Result;
begin
  C.R := GAMMA_INV_TABLE[C.R];
  C.G := GAMMA_INV_TABLE[C.G];
  C.B := GAMMA_INV_TABLE[C.B];
end;

function ApplyCustomGamma(Color: TColor32; GammaTable: TGammaTable8Bit): TColor32;
var
  C: TColor32Entry absolute Color;
  R: TColor32Entry absolute Result;
begin
  C.R := GammaTable[C.R];
  C.G := GammaTable[C.G];
  C.B := GammaTable[C.B];
end;


procedure ApplyGamma(Color: PColor32Array; Length: Integer);
var
  Index: Integer;
begin
  for Index := 0 to Length - 1 do
  begin
    PColor32Entry(Color^).R := GAMMA_TABLE[PColor32Entry(Color^).R];
    PColor32Entry(Color^).G := GAMMA_TABLE[PColor32Entry(Color^).G];
    PColor32Entry(Color^).B := GAMMA_TABLE[PColor32Entry(Color^).B];
    Inc(Color);
  end;
end;

procedure ApplyInvGamma(Color: PColor32Array; Length: Integer);
var
  Index: Integer;
begin
  for Index := 0 to Length - 1 do
  begin
    PColor32Entry(Color^).R := GAMMA_INV_TABLE[PColor32Entry(Color^).R];
    PColor32Entry(Color^).G := GAMMA_INV_TABLE[PColor32Entry(Color^).G];
    PColor32Entry(Color^).B := GAMMA_INV_TABLE[PColor32Entry(Color^).B];
    Inc(Color);
  end;
end;

procedure ApplyCustomGamma(Color: PColor32Array; Length: Integer;
  GammaTable: TGammaTable8Bit);
var
  Index: Integer;
begin
  for Index := 0 to Length - 1 do
  begin
    PColor32Entry(Color^).R := GammaTable[PColor32Entry(Color^).R];
    PColor32Entry(Color^).G := GammaTable[PColor32Entry(Color^).G];
    PColor32Entry(Color^).B := GammaTable[PColor32Entry(Color^).B];
    Inc(Color);
  end;
end;


procedure ApplyGamma(Bitmap: TBitmap32);
begin
  ApplyGamma(Bitmap.Bits, Bitmap.Width * Bitmap.Height);
end;

procedure ApplyInvGamma(Bitmap: TBitmap32);
begin
  ApplyInvGamma(Bitmap.Bits, Bitmap.Width * Bitmap.Height);
end;

procedure ApplyCustomGamma(Bitmap: TBitmap32; GammaTable: TGammaTable8Bit);
begin
  ApplyCustomGamma(Bitmap.Bits, Bitmap.Width * Bitmap.Height, GammaTable);
end;

procedure ApplyCustomGamma(Bitmap: TBitmap32; Gamma: Double);
var
  GammaTable: TGammaTable8Bit;
begin
  if GAMMA_VALUE = Gamma then
    ApplyGamma(Bitmap.Bits, Bitmap.Width * Bitmap.Height)
  else
  begin
    SetGamma(Gamma, GammaTable);
    ApplyCustomGamma(Bitmap.Bits, Bitmap.Width * Bitmap.Height, GammaTable);
  end;
end;


{ Gamma / Pixel Shape Correction table }

procedure SetGamma;
begin
  SetGamma(DEFAULT_GAMMA);
end;

procedure SetGamma(Gamma: Double);
var
  i: Integer;
  InvGamma: Double;
begin
  GAMMA_VALUE := Gamma;

  // calculate default gamma tables
  SetGamma(Gamma, GAMMA_TABLE);
  SetGamma(1 / Gamma, GAMMA_INV_TABLE);
end;

procedure SetGamma(Gamma: Double; GammaTable: TGammaTable8Bit);
var
  i: Integer;
  InvGamma: Double;
begin
  for i := 0 to $FF do
    GammaTable[i] := Round($FF * Power(i * COne255th, Gamma));
end;

end.
