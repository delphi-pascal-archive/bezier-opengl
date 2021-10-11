unit glUtils;

interface

uses opengl,
     math,
     geometry,
     windows;

const
 PI=3.1415926;
 MAX_SINCOS=360*40;
 ANGLE_RADIAN=PI/180;
 X=0;
 Y=1;
 Z=2;

type
 TSinCos=Array [0..MAX_SINCOS] of single;

var


  // Definition of a complete font 
   rasters :array[0..94] of array[0..12] of GLubyte = (
    ($00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00),
    ($00, $00, $18, $18, $00, $00, $18, $18, $18, $18, $18, $18, $18),
    ($00, $00, $00, $00, $00, $00, $00, $00, $00, $36, $36, $36, $36),
    ($00, $00, $00, $66, $66, $ff, $66, $66, $ff, $66, $66, $00, $00),
    ($00, $00, $18, $7e, $ff, $1b, $1f, $7e, $f8, $d8, $ff, $7e, $18),
    ($00, $00, $0e, $1b, $db, $6e, $30, $18, $0c, $76, $db, $d8, $70),
    ($00, $00, $7f, $c6, $cf, $d8, $70, $70, $d8, $cc, $cc, $6c, $38),
    ($00, $00, $00, $00, $00, $00, $00, $00, $00, $18, $1c, $0c, $0e),
    ($00, $00, $0c, $18, $30, $30, $30, $30, $30, $30, $30, $18, $0c),
    ($00, $00, $30, $18, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $18, $30),
    ($00, $00, $00, $00, $99, $5a, $3c, $ff, $3c, $5a, $99, $00, $00),
    ($00, $00, $00, $18, $18, $18, $ff, $ff, $18, $18, $18, $00, $00),
    ($00, $00, $30, $18, $1c, $1c, $00, $00, $00, $00, $00, $00, $00),
    ($00, $00, $00, $00, $00, $00, $ff, $ff, $00, $00, $00, $00, $00),
    ($00, $00, $00, $38, $38, $00, $00, $00, $00, $00, $00, $00, $00),
    ($00, $60, $60, $30, $30, $18, $18, $0c, $0c, $06, $06, $03, $03),
    ($00, $00, $3c, $66, $c3, $e3, $f3, $db, $cf, $c7, $c3, $66, $3c),
    ($00, $00, $7e, $18, $18, $18, $18, $18, $18, $18, $78, $38, $18),
    ($00, $00, $ff, $c0, $c0, $60, $30, $18, $0c, $06, $03, $e7, $7e),
    ($00, $00, $7e, $e7, $03, $03, $07, $7e, $07, $03, $03, $e7, $7e),
    ($00, $00, $0c, $0c, $0c, $0c, $0c, $ff, $cc, $6c, $3c, $1c, $0c),
    ($00, $00, $7e, $e7, $03, $03, $07, $fe, $c0, $c0, $c0, $c0, $ff),
    ($00, $00, $7e, $e7, $c3, $c3, $c7, $fe, $c0, $c0, $c0, $e7, $7e),
    ($00, $00, $30, $30, $30, $30, $18, $0c, $06, $03, $03, $03, $ff),
    ($00, $00, $7e, $e7, $c3, $c3, $e7, $7e, $e7, $c3, $c3, $e7, $7e),
    ($00, $00, $7e, $e7, $03, $03, $03, $7f, $e7, $c3, $c3, $e7, $7e),
    ($00, $00, $00, $38, $38, $00, $00, $38, $38, $00, $00, $00, $00),
    ($00, $00, $30, $18, $1c, $1c, $00, $00, $1c, $1c, $00, $00, $00),
    ($00, $00, $06, $0c, $18, $30, $60, $c0, $60, $30, $18, $0c, $06),
    ($00, $00, $00, $00, $ff, $ff, $00, $ff, $ff, $00, $00, $00, $00),
    ($00, $00, $60, $30, $18, $0c, $06, $03, $06, $0c, $18, $30, $60),
    ($00, $00, $18, $00, $00, $18, $18, $0c, $06, $03, $c3, $c3, $7e),
    ($00, $00, $3f, $60, $cf, $db, $d3, $dd, $c3, $7e, $00, $00, $00),
    ($00, $00, $c3, $c3, $c3, $c3, $ff, $c3, $c3, $c3, $66, $3c, $18),
    ($00, $00, $fe, $c7, $c3, $c3, $c7, $fe, $c7, $c3, $c3, $c7, $fe),
    ($00, $00, $7e, $e7, $c0, $c0, $c0, $c0, $c0, $c0, $c0, $e7, $7e),
    ($00, $00, $fc, $ce, $c7, $c3, $c3, $c3, $c3, $c3, $c7, $ce, $fc),
    ($00, $00, $ff, $c0, $c0, $c0, $c0, $fc, $c0, $c0, $c0, $c0, $ff),
    ($00, $00, $c0, $c0, $c0, $c0, $c0, $c0, $fc, $c0, $c0, $c0, $ff),
    ($00, $00, $7e, $e7, $c3, $c3, $cf, $c0, $c0, $c0, $c0, $e7, $7e),
    ($00, $00, $c3, $c3, $c3, $c3, $c3, $ff, $c3, $c3, $c3, $c3, $c3),
    ($00, $00, $7e, $18, $18, $18, $18, $18, $18, $18, $18, $18, $7e),
    ($00, $00, $7c, $ee, $c6, $06, $06, $06, $06, $06, $06, $06, $06),
    ($00, $00, $c3, $c6, $cc, $d8, $f0, $e0, $f0, $d8, $cc, $c6, $c3),
    ($00, $00, $ff, $c0, $c0, $c0, $c0, $c0, $c0, $c0, $c0, $c0, $c0),
    ($00, $00, $c3, $c3, $c3, $c3, $c3, $c3, $db, $ff, $ff, $e7, $c3),
    ($00, $00, $c7, $c7, $cf, $cf, $df, $db, $fb, $f3, $f3, $e3, $e3),
    ($00, $00, $7e, $e7, $c3, $c3, $c3, $c3, $c3, $c3, $c3, $e7, $7e),
    ($00, $00, $c0, $c0, $c0, $c0, $c0, $fe, $c7, $c3, $c3, $c7, $fe),
    ($00, $00, $3f, $6e, $df, $db, $c3, $c3, $c3, $c3, $c3, $66, $3c),
    ($00, $00, $c3, $c6, $cc, $d8, $f0, $fe, $c7, $c3, $c3, $c7, $fe),
    ($00, $00, $7e, $e7, $03, $03, $07, $7e, $e0, $c0, $c0, $e7, $7e),
    ($00, $00, $18, $18, $18, $18, $18, $18, $18, $18, $18, $18, $ff),
    ($00, $00, $7e, $e7, $c3, $c3, $c3, $c3, $c3, $c3, $c3, $c3, $c3),
    ($00, $00, $18, $3c, $3c, $66, $66, $c3, $c3, $c3, $c3, $c3, $c3),
    ($00, $00, $c3, $e7, $ff, $ff, $db, $db, $c3, $c3, $c3, $c3, $c3),
    ($00, $00, $c3, $66, $66, $3c, $3c, $18, $3c, $3c, $66, $66, $c3),
    ($00, $00, $18, $18, $18, $18, $18, $18, $3c, $3c, $66, $66, $c3),
    ($00, $00, $ff, $c0, $c0, $60, $30, $7e, $0c, $06, $03, $03, $ff),
    ($00, $00, $3c, $30, $30, $30, $30, $30, $30, $30, $30, $30, $3c),
    ($00, $03, $03, $06, $06, $0c, $0c, $18, $18, $30, $30, $60, $60),
    ($00, $00, $3c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $3c),
    ($00, $00, $00, $00, $00, $00, $00, $00, $00, $c3, $66, $3c, $18),
    ($ff, $ff, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00),
    ($00, $00, $00, $00, $00, $00, $00, $00, $00, $18, $38, $30, $70),
    ($00, $00, $7f, $c3, $c3, $7f, $03, $c3, $7e, $00, $00, $00, $00),
    ($00, $00, $fe, $c3, $c3, $c3, $c3, $fe, $c0, $c0, $c0, $c0, $c0),
    ($00, $00, $7e, $c3, $c0, $c0, $c0, $c3, $7e, $00, $00, $00, $00),
    ($00, $00, $7f, $c3, $c3, $c3, $c3, $7f, $03, $03, $03, $03, $03),
    ($00, $00, $7f, $c0, $c0, $fe, $c3, $c3, $7e, $00, $00, $00, $00),
    ($00, $00, $30, $30, $30, $30, $30, $fc, $30, $30, $30, $33, $1e),
    ($7e, $c3, $03, $03, $7f, $c3, $c3, $c3, $7e, $00, $00, $00, $00),
    ($00, $00, $c3, $c3, $c3, $c3, $c3, $c3, $fe, $c0, $c0, $c0, $c0),
    ($00, $00, $18, $18, $18, $18, $18, $18, $18, $00, $00, $18, $00),
    ($38, $6c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $00, $00, $0c, $00),
    ($00, $00, $c6, $cc, $f8, $f0, $d8, $cc, $c6, $c0, $c0, $c0, $c0),
    ($00, $00, $7e, $18, $18, $18, $18, $18, $18, $18, $18, $18, $78),
    ($00, $00, $db, $db, $db, $db, $db, $db, $fe, $00, $00, $00, $00),
    ($00, $00, $c6, $c6, $c6, $c6, $c6, $c6, $fc, $00, $00, $00, $00),
    ($00, $00, $7c, $c6, $c6, $c6, $c6, $c6, $7c, $00, $00, $00, $00),
    ($c0, $c0, $c0, $fe, $c3, $c3, $c3, $c3, $fe, $00, $00, $00, $00),
    ($03, $03, $03, $7f, $c3, $c3, $c3, $c3, $7f, $00, $00, $00, $00),
    ($00, $00, $c0, $c0, $c0, $c0, $c0, $e0, $fe, $00, $00, $00, $00),
    ($00, $00, $fe, $03, $03, $7e, $c0, $c0, $7f, $00, $00, $00, $00),
    ($00, $00, $1c, $36, $30, $30, $30, $30, $fc, $30, $30, $30, $00),
    ($00, $00, $7e, $c6, $c6, $c6, $c6, $c6, $c6, $00, $00, $00, $00),
    ($00, $00, $18, $3c, $3c, $66, $66, $c3, $c3, $00, $00, $00, $00),
    ($00, $00, $c3, $e7, $ff, $db, $c3, $c3, $c3, $00, $00, $00, $00),
    ($00, $00, $c3, $66, $3c, $18, $3c, $66, $c3, $00, $00, $00, $00),
    ($c0, $60, $60, $30, $18, $3c, $66, $66, $c3, $00, $00, $00, $00),
    ($00, $00, $ff, $60, $30, $18, $0c, $06, $ff, $00, $00, $00, $00),
    ($00, $00, $0f, $18, $18, $18, $38, $f0, $38, $18, $18, $18, $0f),
    ($18, $18, $18, $18, $18, $18, $18, $18, $18, $18, $18, $18, $18),
    ($00, $00, $f0, $18, $18, $18, $1c, $0f, $1c, $18, $18, $18, $f0),
    ($00, $00, $00, $00, $00, $00, $06, $8f, $f1, $60, $00, $00, $00)

);

  // Font
  fontOffset : GLuint;                // Offset for the Display list

   white : array[0..2] of GLfloat = ( 1.0, 1.0, 1.0 );
   blue  : array[0..2] of GLfloat = ( 0.0, 0.0, 1.0 );
   red   : array[0..2] of GLfloat = ( 1.0, 0.0, 0.0 );
   green : array[0..2] of GLfloat = ( 0.0, 1.0, 0.0 );
   black : array[0..2] of GLfloat = ( 0.0, 0.0, 0.0 );

 CosTab,SinTab:TSinCos;

 function VectorProject(Pov:TVector3f;ToProject:TVector3f;z:single) : TVector3f;

 function VectorNormale(V1,V2,V3:TAffineVector):TAffineVector;

 function VectorRotateX(V:TAffineVector;Angle:single):TAffineVector;
 function VectorRotateY(V:TAffineVector;Angle:single):TAffineVector;
 function VectorRotateZ(V:TAffineVector;Angle:single):TAffineVector;

 procedure MakeTCos(var c:TSinCos);
 function  GetCos(x:integer):single;
 function  GetSin(x:integer):single;

 function IntToStr(Num : Integer) : String;
 procedure PrintString(s : string);
 procedure MakeRasterFont;

implementation

 uses GFX;

{------------------------------------------------------------------}
function IntToStr(Num : Integer) : String;  // using SysUtils increase file size by 100K
begin
  Str(Num, result);
end;

{------------------------------------------------------------------}
{  Create the display lists for our raster font                    }
{------------------------------------------------------------------}
procedure MakeRasterFont;
var i : GLuint;
begin
    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);      // set the bit alignment
    fontOffset := glGenLists (128);             // generate 128 display lists
    for i := 32 to 126 do
    begin
        glNewList(i+fontOffset, GL_COMPILE);    // Create but dont execute a list
            glBitmap(8, 13, 0.0, 2.0, 10.0, 0.0, @rasters[i-32]); // Add a character to the current Display list
        glEndList();                            // End the display list creation
    end;
end;


{------------------------------------------------------------------}
{  Draw a string of characters to the scene                        }
{------------------------------------------------------------------}
procedure PrintString(s : string);
begin
  glPushAttrib (GL_LIST_BIT);
  glColor3fv(@black);
    glListBase(fontOffset);
    glCallLists(length(s), GL_UNSIGNED_BYTE,  PChar(s));
  glPopAttrib();
end;



 procedure MakeTCos(var c:TSinCos);
  var i:integer;
  begin
   while (i<=MAX_SINCOS) do begin
    c[i]:=cos(i*2*PI/MAX_SINCOS);
    inc(i);
   end;
  end;

 procedure MakeTSin(var s:TSinCos);
  var i:integer;
  begin
   while (i<=MAX_SINCOS) do begin
    s[i]:=sin(i*2*PI/MAX_SINCOS);
    inc(i);
   end;
  end;

 function GetCos(x:integer):single;
  begin
   result:=CosTab[x mod MAX_SINCOS];
  end;

 function GetSin(x:integer):single;
  begin
   result:=SinTab[x mod MAX_SINCOS];
  end;

//------------------------------------------------------------------------------

function VectorRotateX(V:TAffineVector;Angle:single):TAffineVector;
 var MRot:TMatrix3f;
     c,s:single;
 begin
  angle:=angle*ANGLE_RADIAN;
  c:=Cos(Angle); s:=Sin(Angle);
  //creation de la matrice de rotation
  MRot[X][X]:=1;   MRot[Y][X]:=0;   MRot[Z][X]:=0;
  MRot[X][Y]:=0;   MRot[Y][Y]:=c;   MRot[Z][Y]:=-s;
  MRot[X][Z]:=0;   MRot[Y][Z]:=s;   MRot[Z][Z]:=C;
  //applique la rotation
  result:=VectorAffineTransform(V,MRot);
 end;

function VectorRotateY(V:TAffineVector;Angle:single):TAffineVector;
 var MRot:TMatrix3f;
     c,s:single;
 begin
  angle:=angle*ANGLE_RADIAN;
  c:=Cos(Angle); s:=Sin(Angle);
  //creation de la matrice de rotation
  MRot[X][X]:=c;  MRot[Y][X]:=0;   MRot[Z][X]:=-s;
  MRot[X][Y]:=0;  MRot[Y][Y]:=1;   MRot[Z][Y]:=0;
  MRot[X][Z]:=-s; MRot[Y][Z]:=0;   MRot[Z][Z]:=c;
  //applique la rotation
  result:=VectorAffineTransform(V,MRot);
 end;

function VectorRotateZ(V:TAffineVector;Angle:single):TAffineVector;
 var MRot:TMatrix3f;
     c,s:single;
 begin
  angle:=angle*ANGLE_RADIAN;
  c:=Cos(Angle); s:=Sin(Angle);
  //creation de la matrice de rotation
  MRot[X][X]:=c;   MRot[Y][X]:=-s;   MRot[Z][X]:=0;
  MRot[X][Y]:=s;   MRot[Y][Y]:=c;    MRot[Z][Y]:=0;
  MRot[X][Z]:=0;   MRot[Y][Z]:=0;    MRot[Z][Z]:=1;
  //applique la rotation
  result:=VectorAffineTransform(V,MRot);
 end;

function VectorNormale(V1,V2,V3:TAffineVector):TAffineVector;
 begin
  result:=VectorCrossProduct(VectorAffineSubtract(V1,V2),(VectorAffineSubtract(V3,V2)));
 end;

//------------------------------------------------------------------------------

function VectorProject(Pov:TVector3f;ToProject:TVector3f;z:single) : TVector3f;
var
  k : double;
begin
  result:=ToProject;

  if (pov[2] - z < 0) then begin
      if((ToProject[2]-pov[2]) < 0.0000001) then exit;
  end
  else if(camera.pos.z - z > 0) then begin
      if((ToProject[2]-pov[2]) > 0.0000001) then exit;
  end
  else
   exit;

  k := (pov[2]-z) / (ToProject[2]-pov[2]);

  result[0] := pov[0] - k*(ToProject[0]-pov[0]);
  result[1] := pov[1] - k*(ToProject[1]-pov[1]);
  result[2] := z;
end;


begin
 //MakeTCos(CosTab);
 //MakeTSin(SinTab);
end.
