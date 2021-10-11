unit glBezier;

interface

uses
Gl,
Glu,
Glext,
Math,
Geometry,
contnrs,
glUtils,
textures;

const
  // Control Points for texture
  TEXPTSDEF : array [0..1] of array [0..1] of array[0..1] of GLfloat = (
    ((0.0, 0.0), (0.0, 1.0)),
    ((1.0, 0.0), (1.0, 1.0))
    );

type
TglBezierSurface = class
 private
  start_time:cardinal;
  ctrlPts:array of array of TVector4f;
 public
  s_vitesse,s_width,s_height,s_min_bounce:single;
  s_x_def,s_y_def:smallint;
  constructor Create(w,h:single;xdef,ydef:smallint);
  procedure   Render(dt:cardinal);
  procedure   Bounce(x,y:integer;b:single);
  procedure   RandBounce();
end;

TglBezierLine  = class
 ad,md:byte;
 l:char;
 c:array [0..3] of single;
 Pts:array of TVector3f;
 constructor Create(mdef,adef:byte;R,G,B:single);
 procedure Render;
 procedure RandMove(dt:cardinal;r:boolean); virtual;
end;

TglBezierLine2  = class(TglBezierLine)
 procedure RandMove(dt:cardinal;r:boolean); override;
end;

TglBezierLine3  = class(TglBezierLine)
 procedure RandMove(dt:cardinal;r:boolean); override;
end;

TglBezierLines = class
 private
  st:cardinal;
  Lines:array of TglBezierLine;
 public
  Count:byte;
  constructor Create(c:byte);
  procedure   Render(dt:cardinal);
  destructor  Free;
end;

var
Bezier : TglBezierSurface;
BezierL: TglBezierLines;

implementation

uses windows;

constructor TglBezierSurface.Create(w,h:single;xdef,ydef:smallint);
 var i,j:integer;
 begin
  s_vitesse := 0.998;
  s_min_bounce := 0.01;
  s_width   := w;
  s_height  := h;
  s_x_def   := xdef;
  s_y_def   := ydef;

  SetLength( ctrlPts, s_x_def, s_y_def );
  for i:=0 to s_x_def-1 do
  for j:=0 to s_y_def-1 do begin
   ctrlPts[i,j][0] := s_width*i/(s_x_def-1);
   ctrlPts[i,j][1] := s_height*j/(s_y_def-1);
   ctrlPts[i,j][2] := randomrange(-50,50)/10;
  end;

  glMap2f(GL_MAP2_VERTEX_3, 0, 1, 3, 4,
      0, 1, 12, 4, @ctrlPts[0][0][0]);                    // Add the control points for the Mesh
  glMap2f(GL_MAP2_TEXTURE_COORD_2, 0, 1, 2, 2,
      0, 1, 4, 2, @TEXPTSDEF[0][0][0]);                         // Add the Texture COntrol Points for the mesh
  //glEnable(GL_MAP2_TEXTURE_COORD_2);                         // Enable Auto Texture U V Generation
  glEnable(GL_MAP2_VERTEX_3);                                // Enable Auto Vertex Generation
  glMapGrid2f(s_x_def, 0.0, 1.0, s_y_def, 1.0, 0.0);                   // Create a 20x20 grid

  {LoadImage();                                               // Load the Image
  glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_DECAL);  // Set the Texturing to Decal
  glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S,
                   GL_REPEAT);                               // Repeat on the Texture on S
  glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T,
                   GL_REPEAT);                               // Repeat on the Texture on T
  glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER,
                   GL_NEAREST);                              // Set the Magnification factor to use the nearest pixels
  glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER,
                   GL_NEAREST);                              // Set the Minification factor to use the nearest pixels
  glTexImage2D(GL_TEXTURE_2D, 0, 3, IMAGE_WIDTH, IMAGE_HEIGHT,
                   0, GL_RGB, GL_UNSIGNED_BYTE, @image);     // Load the texture into Video Memory
  glEnable(GL_TEXTURE_2D);                                   // Enable Texuring }

  //glEnable(GL_AUTO_NORMAL);
  //glEnable(GL_NORMALIZE);                                    // Auto Normalize
  //glShadeModel (GL_FLAT);
  //glDisable(GL_BLEND);

  start_time := gettickcount;
 end;



procedure TglBezierSurface.Render(dt:cardinal);
 var
  i,j:integer;
  cg,sg:single;
 begin


  if GetTickCount - start_time > 5 then begin
  cg:=cos(GetTickCount/1000)/10;
  sg:=sin(GetTickCount/1000)/10;
  for i:=0 to s_x_def-1 do
  for j:=0 to s_y_def-1 do
   if abs(ctrlPts[i,j][2]) > s_min_bounce then begin
    ctrlPts[i,j][0] := s_width*i/(s_x_def-1) + cos(ctrlPts[i,j][2])*ctrlPts[i,j][0]*sg;
    ctrlPts[i,j][1] := s_height*j/(s_y_def-1) + sin(ctrlPts[i,j][2])*ctrlPts[i,j][1]*cg;
    ctrlPts[i,j][2] := ctrlPts[i,j][2] * s_vitesse;
    ctrlPts[i,j][3] := ctrlPts[i,j][3] * s_vitesse;
   end else begin
    ctrlPts[i,j][0] := ctrlPts[i,j][0] + cg;
    ctrlPts[i,j][1] := ctrlPts[i,j][1] + sg;
   end;
  glColor4f(0.6,0.4,0.1,0.1);
  glMap2f(GL_MAP2_VERTEX_3, 0, 1, 3, 4,
      0, 1, 12, 4, @ctrlPts[0][0][0]);                    // Add the control points for the Mesh
  start_time:=GetTickCount;
  end;


  glEvalMesh2(GL_LINE,0,s_x_def,0,s_y_def);
 end;



procedure TglBezierSurface.Bounce(x,y:integer;b:single);
 begin
  ctrlPts[x,y][2]:=ctrlPts[x,y][2]*b+cos(GetTickCount/1000)/10;
 end;

procedure TglBezierSurface.RandBounce();
 var x,y,c:smallint;
 begin
   c:=random(round(2*sqrt(s_x_def*s_y_def)));
   While c > 0 do begin
    x:=random(s_x_def);
    y:=random(s_y_def);
    ctrlPts[x,y][2]:=ctrlPts[x,y][2]*((50+random(50))/100)*cos(GetTickCount/1000)/10;
    dec(c);
   end;
 end;

{------------------------------------------------------------------------------}

constructor TglBezierLine.Create(mdef,adef:byte;R,G,B:single);
 var i,j:integer;
     rd:byte;
 begin
  ad:=adef;
  md:=mdef;
  SetLength(Pts,md);
  Pts[0][0] := randomrange(-100,100)/10;
  Pts[0][1] := randomrange(-100,100)/10;
  Pts[0][2] := randomrange(-200,200)/10;
  c[0] := R;
  c[1] := G;
  c[2] := B;
  c[3] := 0;

  l:=char(randomrange(65,90));

  for i := 1 to md-1 do begin
   rd := random(255);
   j := round(power(-1,random(10)));
   if rd mod 3 = 0 then
    Pts[i] := VectorRotateX( Pts[i-1], j*(10+random(100)/7) )
   else if rd mod 2 = 0 then
    Pts[i] := VectorRotateY( Pts[i-1], j*(30+random(100)/5) )
   else
    Pts[i] := VectorRotateZ( Pts[i-1], j*(10+random(100)/7) );
  end;
 end;

procedure TglBezierLine.RandMove(dt:cardinal;r:boolean);
 var i,rd:integer;
 begin
  if r then
  for i := md-1 downto 1 do
   Pts[i]:=Pts[i-1];

    Pts[0][0] := Pts[0][0] - ( c[0] * cos(GetTickCount/2000)/10 + cos(GetTickCount/(200*c[0]))/(30*c[1]) ) * cos(GetTickCount/(3000*c[0])+Pts[0][0])/30 + c[2] * sin(GetTickCount/500)/10 - c[2] * c[1] * c[0] * cos(GetTickCount/200)/10;
    Pts[0][1] := Pts[0][1] + ( c[1] * sin(GetTickCount/2000)/10 + sin(GetTickCount/(200*c[1]))/(30*c[0]) ) * sin(GetTickCount/(3000*c[1])+Pts[0][1])/30 - c[2] * cos(GetTickCount/500)/10 + c[2] * c[1] * c[0] * cos(GetTickCount/200)/10;
    Pts[0][2] := Pts[0][2] + sin(GetTickCount/1500)*c[2]/10;

   {rd := random(255);
   i := round(power(-1,random(10)));
   if rd mod 3 = 0 then
    Pts[0] := VectorRotateX( Pts[0], i*(0.09+random(100)/200) )
   else if rd mod 2 = 0 then
    Pts[0] := VectorRotatez( Pts[0], i*(0.09+random(100)/200) );
   }
 end;

procedure TglBezierLine2.RandMove(dt:cardinal;r:boolean);
 var i,rd:integer;
 begin
  if r then
  for i := md-1 downto 1 do
   Pts[i]:=Pts[i-1];

    Pts[0][0] := Pts[0][0] - ( c[0] * cos(GetTickCount/1000)/10 + cos(GetTickCount/(100*c[0]))/(20*c[1]) ) * sin(GetTickCount/(4000*c[0])+Pts[0][0])/30 + c[2] * cos(GetTickCount/700)/10 - c[2] * c[1] * c[0] * sin(GetTickCount/150)/10;
    Pts[0][1] := Pts[0][1] + ( c[1] * sin(GetTickCount/1200)/10 + sin(GetTickCount/(100*c[1]))/(20*c[0]) ) * cos(GetTickCount/(4000*c[1])+Pts[0][1])/30 - c[2] * sin(GetTickCount/700)/10 + c[2] * c[1] * c[0] * sin(GetTickCount/150)/10;
    Pts[0][2] := Pts[0][2] + sin(GetTickCount/1500)*c[2]/10;

   {rd := random(255);
   i := round(power(-1,random(10)));
   if rd mod 3 = 0 then
    Pts[0] := VectorRotateX( Pts[0], i*(0.09+random(100)/200) )
   else if rd mod 2 = 0 then
    Pts[0] := VectorRotatez( Pts[0], i*(0.09+random(100)/200) );
   }
 end;

procedure TglBezierLine3.RandMove(dt:cardinal;r:boolean);
 var i,rd:integer;
 begin
  if r then
  for i := md-1 downto 1 do
   Pts[i]:=Pts[i-1];

    Pts[0][0] := Pts[0][0] - c[2] * sin(GetTickCount/250)/60 + cos(GetTickCount/1050)/10 - c[2] * c[1] * c[0] * sin(GetTickCount/2500)/5 + sin(GetTickCount/(200*c[0]))/(10*c[1]) * sin(GetTickCount/(3000*c[0])+Pts[0][0])/30;
    Pts[0][1] := Pts[0][1] + c[2] * cos(GetTickCount/600)/10 + cos(GetTickCount/(2000*c[1]))/(60*c[0])  * sin(GetTickCount/(750*c[0])) + cos(GetTickCount/(200*c[1]))/(10*c[0]) * cos(GetTickCount/(3000*c[1])+Pts[0][1])/30 - c[1];
    Pts[0][2] := Pts[0][2] + sin(GetTickCount/1500)*c[2]/10;

   {rd := random(255);
   i := round(power(-1,random(10)));
   if rd mod 3 = 0 then
    Pts[0] := VectorRotateX( Pts[0], i*(0.09+random(100)/200) )
   else if rd mod 2 = 0 then
    Pts[0] := VectorRotatez( Pts[0], i*(0.09+random(100)/200) );
   }
 end;

procedure TglBezierLine.Render();
 var i:integer;
     f:single;
 begin
  glMap1f(GL_MAP1_VERTEX_3, 0.0, 1.0, 3, md,@Pts[0][0]);
  glEnable(GL_MAP1_VERTEX_3);

  i := random(5);

  f := c[3];

  if i mod 2 = 0 then begin
    glLineWidth(1.8);
    glBegin(GL_LINE_STRIP);
        glColor4f(c[0]*1.5,c[1]*1.5,c[2]*1.5,0.5);
        glEvalCoord1f(0);
        for i := 1 to ad do begin
            c[3]:=i/ad;
            glColor4f(1,1,1,1-c[3]);
            glEvalCoord1f(c[3]);
        end;
    glEnd();
  end else begin
    glLineWidth(i*1.5);
    glBegin(GL_LINE_STRIP);
        glColor4f(1,1,1,0.1);
        glEvalCoord1f(0);
        for i := 1 to ad do begin
            c[3]:=i/ad;
            glColor4f((c[0]+abs(cos(Pts[0][1]/100)))/4,(c[1] + abs(sin(Pts[0][0]/100))/2)/2,c[2]*2,1-c[3]);
            glEvalCoord1f(c[3]);
        end;
    glEnd();
  end;

 glDisable(GL_MAP1_VERTEX_3);

  {glPushMatrix;
   glColor4f(1,1,1,0.6);
   glRasterPos3fv(@Pts[0]);
    PrintString(l);
  glPopMatrix;}

  for i:=1 to 8 do begin
   c[3]:=i/9;
   glPointSize(i * 3);
    glColor4f(1.2-(1-c[0])*c[3],1.2-(1-c[1])*c[3],1.2-(1-c[2])*c[3],c[3]*0.02);
   glBegin(GL_POINTS);
    glVertex3fv(@Pts[0]);
   glEnd;
  end;





  f := f + GetTickCount/1000000;
  if f>=1 then
   c[3] := 0.0
  else
   c[3] := f;

  glPointSize(1);
 end;

{------------------------------------------------------------------------------}

constructor TglBezierLines.Create(c:byte);
 var i,r:integer;
 begin
  randomize;
  Count := c;
  st := GetTickCount;
  SetLength( Lines, count );

  for i:=0 to count-1 do begin
   r := random(5);
   if r=2 then
     Lines[i] := TglBezierLine2.Create(5,11,0.1+random(30)/100,0.4+random(10)/6,0.5+random(10)/6)
   {else if r=0 then
     Lines[i] := TglBezierLine3.Create(10,15,0.1+random(7)/7,0.5+random(9)/6,0.6+random(10)/6)}
   else
     Lines[i] := TglBezierLine.Create(22,45,0.4+random(10)/6,0.4+random(10)/6,0.5+random(10)/6);
  end;
 end;

procedure TglBezierLines.Render(dt:cardinal);
 var i:integer;
 begin

 glEnable(GL_POINT_SMOOTH );
 glEnable(GL_LINE_SMOOTH );

  glEnable(GL_BLEND);
  if GetTickCount-st>10 then begin
    for i:=0 to count-1 do begin
      Lines[i].RandMove(dt,true);
      Lines[i].Render();
    end;
    st:=getTickCount;
  end else begin
    for i:=0 to count-1 do begin
      Lines[i].RandMove(dt,false);
      Lines[i].Render();
    end;
  end;
  glDisable(GL_BLEND);

 glDisable(GL_POINT_SMOOTH );
 glDisable(GL_LINE_SMOOTH );
 end;

destructor  TglBezierLines.Free;
 var
  i:integer;
 begin
  for i := 0 to Count-1 do
   Lines[i].Free;
 end;

end.
