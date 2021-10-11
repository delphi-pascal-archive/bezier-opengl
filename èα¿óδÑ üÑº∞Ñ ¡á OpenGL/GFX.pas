unit GFX;

interface

Uses  Windows,
      GL,
      StrUtils,
      geometry;

type
  TVect = record
    x, y, z, t  : single;
  end;
  PVect = ^TVect;

  TPlane = array [0..3] of single;

  TCamera = class
  public
    pos, rot : TVect;
    mat_model, mat_proj : array[0..15] of double;
    clip_far : integer;
    fov : single;
    moved : boolean;

    procedure calc_frustum();
//    function point_in_frustum(x, y, z : single) : boolean;
    function point_in_frustum(pt : TVector3f; size:single=0.01) : boolean; overload;
    function point_in_frustum(x, y, z, size : single) : boolean; overload;
    procedure draw();
    procedure perspective();
  private
    clip : array [0..15] of single;         // matrice de clipping
    fFrustum : array [0..5] of TPlane;      // 6 plans x 4 coefficients
  end;

const

  frustum_RIGHT   = 0;
  frustum_LEFT    = 1;
  frustum_BOTTOM  = 2;
  frustum_TOP     = 3;
  frustum_FAR     = 4;
  frustum_NEAR    = 5;

  A_NOUVEAU      = 0;
  A_OUVRIR       = 1;
  A_ENREGISTRER  = 2;
  A_ENREGISTRERS = 3;



procedure DetruireFenetreGL(h_Wnd:HWND; PleinEcran:Boolean);  //  Detruit  la fenetre et ferme OpenGL
function  CreerFenetreGL( Titre:String;            //  Crée la fenetre OpenGL
                          X, Y, Largeur, Hauteur:Integer;
                          PleinEcran:Boolean;
                          ProfCouleur:Integer;
                          hParent:HWND) : HWND;
procedure CreerRC(fenetreGL:HWND; pleinecran:boolean);

const WND_CLASS = 'FenetreGL';

procedure glColor1ub(lum:byte);

procedure InitDraw();
procedure Draw();

const

  ambient : array [0..3] of GLfloat = ( 0.2, 0.2, 0.2, 1.0 );
  position : array [0..3] of GLfloat = ( 0.0, 0.0, 2.0, 1.0 );
  mat_diffuse : array [0..3] of GLfloat = ( 0.6, 0.6, 0.6, 1.0 );
  mat_specular : array [0..3] of GLfloat = ( 1.0, 1.0, 1.0, 1.0 );


  mat_shininess : GLfloat =  50.0 ;






var
  mb_bas : single = 0.15;
  mb_haut : single = 0.1;
  nb_lines : byte = 60; 



  ///
  viewport : array[0..3] of integer;
  camera : TCamera;

  ticks, dticks, frames, frames_ticks : cardinal;




  glresize : boolean;


implementation

Uses  Sysutils,
      Messages,
      GLu,
      glUtils,
      gui,
      math,
      input,
      glBezier,
      textures;

var
  h_DC  : hDC;
  h_RC  : hGLRC;

  bg_tex:cardinal;






//  ticks, dticks, frames, frames_ticks : cardinal;
procedure InitLights();
begin                                                            // Enable Lighting
    glEnable(GL_LIGHTING);                                       // Enable Light 0
    glEnable(GL_LIGHT0);

    glLightfv(GL_LIGHT0, GL_AMBIENT, @ambient);                  // The the Ambient value for the light
    glLightfv(GL_LIGHT0, GL_POSITION, @position);                // Set the Position of the light
    glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, @mat_diffuse);   // Set the Diffuse Material
    glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, @mat_specular); // Set the Specular Material
    glMaterialfv(GL_FRONT_AND_BACK,GL_SHININESS, @mat_shininess);// Set the Shininess of the Material
end;


//  Initialise le dessin
procedure InitDraw();
begin
  glResize := true;
  
  glClearColor(0.01, 0.05, 0.05, 1);

  //LoadTexture( 'tex/bg.bmp', bg_tex, false );

  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity();

  camera := TCamera.Create();
  camera.clip_far := 500;
  camera.pos.x := 0;    camera.pos.y := 0;    camera.pos.z := 10; camera.pos.t:=1;
  camera.rot.x:=0;
  camera.moved := true;





  glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);
  glEnable(GL_DEPTH_TEST);


  glEnable(GL_COLOR_MATERIAL);
   glTexEnvi( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE );

   glBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );

  //
    //config lumiere de base
    //InitLights();
  //

  //
    //Genere les fonts Opengl
    //MakeRasterFont;
  //


  //
    //courbes de bezier
    //Bezier := TglBezierSurface.Create(20,20,20,20);
    BezierL := TglBezierLines.Create(30);
  //

end;

procedure MoveX(d:single);
 begin
   camera.pos.x := camera.pos.x + d;
 end;

procedure MoveY(d:single);
 begin
   camera.pos.y := camera.pos.y + d;
 end;

procedure MoveDown(d:single);
 begin
  camera.pos.y := camera.pos.y - cos(camera.rot.y*3.14159/180)*d;
  camera.pos.x := camera.pos.x - sin(camera.rot.y*3.14159/180)*d;
 end;

procedure MoveUp(d:single);
 begin
  camera.pos.y := camera.pos.y + cos(camera.rot.y*3.14159/180)*d;
  camera.pos.x := camera.pos.x + sin(camera.rot.y*3.14159/180)*d;
 end;

procedure MoveLeft(d:single);
 begin
  camera.pos.y := camera.pos.y - cos((camera.rot.y+90)*3.14159/180)*d;
  camera.pos.x := camera.pos.x - sin((camera.rot.y+90)*3.14159/180)*d;
 end;

procedure MoveRight(d:single);
 begin
  camera.pos.y := camera.pos.y - cos((camera.rot.y-90)*3.14159/180)*d;
  camera.pos.x := camera.pos.x - sin((camera.rot.y-90)*3.14159/180)*d;
 end;


//  Dessine
procedure Draw();
var
  newTicks : cardinal;

begin


  do_input(dticks);

  if(glresize) then begin
    glViewport(viewport[0],viewport[1],viewport[2],viewport[3]);

    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    camera.perspective();

    glMatrixMode(GL_MODELVIEW);

    glresize := false;
  end;

  glLoadIdentity();

   glpushmatrix();

   //transformations pour le point de vue
   camera.draw();

  if(camera.moved) then begin
    glGetDoublev(GL_MODELVIEW_MATRIX, @camera.mat_model[0]);
    camera.calc_frustum();
    camera.moved := false;
  end;


  glClear({GL_COLOR_BUFFER_BIT or }GL_DEPTH_BUFFER_BIT{ or GL_STENCIL_BUFFER_BIT});

  //////////////////////////////////////

  glDepthFunc(GL_LESS);
  glMatrixMode(GL_PROJECTION);
   glPushMatrix;
    glLoadIdentity;
    glOrtho(0,1,1,0,-1,10);
  glMatrixMode(GL_MODELVIEW);
   glPushMatrix;
    glLoadIdentity;

 { glEnable(GL_TEXTURE_2D);
  glBindTexture( GL_TEXTURE_2D, bg_tex );  }
  glEnable(GL_BLEND);
   glBegin(GL_QUADS);
    glColor4f(0.05,0.1,0.1,mb_bas);
     glTexCoord2f(0,1);
     glVertex3i(0,1,-1);
    glColor4f(0.2,0.2,0.3,mb_haut);
     glTexCoord2f(0,0);
     glVertex3i(0,0,-1);
     glTexCoord2f(1,0);
     glVertex3i(1,0,-1);
    glColor4f(0.05,0.1,0.1,mb_bas);
     glTexCoord2f(1,1);    
     glVertex3i(1,1,-1);
   glEnd;
  glDisable(GL_BLEND);
 { glDisable(GL_TEXTURE_2D);  }

  glMatrixMode(GL_PROJECTION);
   glPopMatrix();

  glMatrixMode(GL_MODELVIEW);
   glPopMatrix();

    glRotatef(GetTickCount/300,0.6,0.3,0.3);
    //glTranslatef(10*cos(GetTickCount/4500),10*sin(GetTickCount/4800),3*sin(GetTickCount/4000));

    glDepthFunc(GL_ALWAYS);



    //Bezier.Render(dticks);
    BezierL.Render(dticks);



  //////////////////////////////////////

  glpopmatrix();

  if BezierL.Count <> nb_lines then begin
    BezierL.Free;
    BezierL:=TglBezierLines.Create(nb_lines);
  end;

  glFinish();
  SwapBuffers(h_DC);

  newTicks := GetTickCount();
  dticks := newTicks - ticks;
  ticks := newTicks;

  frames := frames + 1;
  frames_ticks := frames_ticks + dticks;
  if(frames_ticks > 420) then begin
    frmMain.StatusBar.Panels.Items[0].Text := IntToStr(Round(frames * 1000 / frames_ticks));
    frames := 0;
    frames_ticks := 0;
  end;



end;


procedure TCamera.perspective();
begin
    gluPerspective(70, viewport[2]/viewport[3], 1, clip_far);
    glGetDoublev(GL_PROJECTION_MATRIX, @mat_proj[0]);
    moved := true;
end;

procedure TCamera.draw();
begin
  glRotatef(-rot.x, 1, 0, 0);
  glRotatef(-rot.z, 0, 1, 0);
  glRotatef(-rot.y, 0, 0, 1);

  glTranslatef(-pos.x, -pos.y, -pos.z);
end;


//  Procedure de la fenetre
function WndProc(hWnd: HWND; Msg: UINT;  wParam: WPARAM;  lParam: LPARAM): LRESULT; stdcall;
var newX,newY:integer;
begin
  result := 0;
  case (Msg) of
{    // clavier
    WM_KEYDOWN: if((lParam  and (1 shl 30)) = 0) then
                   OnKeyDown(wParam, lParam);
    WM_KEYUP: OnKeyUp(wParam, lParam);

    // souris
    WM_LBUTTONDOWN: begin
                         mouse.btn[0] := true;
                         mouse.btnOld[0] := false;
    end;
    WM_MBUTTONDOWN: begin
                         mouse.btn[1] := true;
                         mouse.btnOld[1] := false;
    end;
    WM_RBUTTONDOWN: begin
                         mouse.btn[2] := true;
                         mouse.btnOld[2] := false;
    end;
    WM_LBUTTONUP: begin
                         mouse.btn[0] := false;
                         mouse.btnOld[0] := true;
    end;
    WM_MBUTTONUP: begin
                         mouse.btn[1] := false;
                         mouse.btnOld[1] := true;
    end;
    WM_RBUTTONUP: begin

    end;

    WM_MBUTTONDOWN: begin

    end;

    WM_LBUTTONDOWN: begin
     glMouse.ApplyTool:=true;
    end;  }

    WM_MOUSEMOVE: begin
      if((wParam and MK_RBUTTON) <> 0) then begin
        camera.rot.y := camera.rot.y + (mouse.x-LOWORD(lParam));
        camera.rot.x := camera.rot.x + (mouse.y-HIWORD(lParam));
        if(camera<>nil) then
          camera.moved := true;
      end;

       mouse.x := LOWORD(lParam);
       mouse.y := HIWORD(lParam);
    end;

//    WM_REZAL: CliRezalMessage(wParam, lParam);

   { WM_CREATE: begin

    end;  }

    WM_SIZE:
    if(wParam<>SIZE_MINIMIZED) then begin
        viewport[2] := LOWORD(lParam);
        viewport[3] := HIWORD(lParam);
        glresize := true;
        Result := 0;
    end;

(*    WM_TIMER: begin
      Draw();
    end;
*)
    else
      Result := DefWindowProc(hWnd, Msg, wParam, lParam);    // Default result if nothing happens
  end;
end;




//  Detruit  la fenetre et ferme OpenGL
procedure DetruireFenetreGL(h_Wnd:HWND; PleinEcran:Boolean);
begin
  if PleinEcran then             // Sort du mode plein ecran
  begin
    ChangeDisplaySettings(devmode(nil^), 0);
    ShowCursor(True);
  end;

  wglMakeCurrent(h_DC, 0);

  wglDeleteContext(h_RC);
  h_RC := 0;

  if(h_DC > 0) then ReleaseDC(h_Wnd, h_DC);
  h_DC := 0;

  if (h_Wnd <> 0) then DestroyWindow(h_Wnd);

  UnRegisterClass(WND_CLASS, hInstance);
  hInstance := 0;
end;


//////////

//  Crée la fenetre OpenGL
function CreerFenetreGL(Titre:String; X,Y,Largeur,Hauteur:Integer; PleinEcran:Boolean; ProfCouleur:Integer; hParent:HWND) : HWND;
var
  wndClass : TWndClass;         // Window class
  dwStyle : DWORD;              // Window styles
  dwExStyle : DWORD;            // Extended window styles
  dmScreenSettings : DEVMODE;   // Screen settings (PleinEcran, etc...)
  PixelFormat : GLuint;         // Settings for the OpenGL rendering
  h_Instance : HINST;           // Current instance
  pfd : TPIXELFORMATDESCRIPTOR;  // Settings for the OpenGL window
begin
  h_Instance := GetModuleHandle(nil);       //Grab An Instance For Our Window
  ZeroMemory(@wndClass, SizeOf(wndClass));  // Clear the window class structure

  with wndClass do                    // Set up the window class
  begin
    style         := CS_HREDRAW or    // Redraws entire window if length changes
                     CS_VREDRAW or    // Redraws entire window if Hauteur changes
                     CS_OWNDC;        // Unique device context for the window
    lpfnWndProc   := @WndProc;        // Set the window procedure to our func WndProc
    hInstance     := h_Instance;
    hCursor       := LoadCursor(0, IDC_ARROW);
    lpszClassName := WND_CLASS;
  end;

  if (RegisterClass(wndClass) = 0) then  // Attemp to register the window class
  begin
    MessageBox(0, 'Failed to register the window class!', 'Error', MB_OK or MB_ICONERROR);
    Result := 0;
    Exit
  end;

  // Change to PleinEcran if so desired
  if PleinEcran then
  begin
    ZeroMemory(@dmScreenSettings, SizeOf(dmScreenSettings));
    with dmScreenSettings do begin              // Set parameters for the screen setting
      dmSize       := SizeOf(dmScreenSettings);
      dmPelsWidth  := Largeur;                    // Window Largeur
      dmPelsHeight := Hauteur;                   // Window Hauteur
      dmBitsPerPel := ProfCouleur;               // Window color depth
      dmFields     := DM_PELSWIDTH or DM_PELSHEIGHT or DM_BITSPERPEL;
    end;

    // Try to change screen mode to PleinEcran
    if (ChangeDisplaySettings(dmScreenSettings, CDS_FULLSCREEN) = DISP_CHANGE_FAILED) then
    begin
      MessageBox(0, 'Le mode plein écran a échoué !', 'GFX', MB_OK or MB_ICONERROR);
      PleinEcran := False;
    end;
  end;

  // If we are (still) in PleinEcran then
  if (PleinEcran) then
  begin
    dwStyle := WS_POPUP or                // Creates a popup window
               WS_CLIPCHILDREN            // Doesn't draw within child windows
               or WS_CLIPSIBLINGS;        // Doesn't draw within sibling windows
    dwExStyle := WS_EX_APPWINDOW;// or       // Top level window
//                 WS_EX_TOPMOST;
//    ShowCursor(False);                    // Turn of the cursor (gets in the way)
  end
  else
  begin
    dwStyle := WS_CLIPCHILDREN or         // Doesn't draw within child windows
               WS_CLIPSIBLINGS;           // Doesn't draw within sibling windows
    if(hParent <> 0) then begin
      dwStyle := dwStyle or WS_CHILD;
      dwExStyle := 0;
    end
    else begin
      dwStyle := dwStyle or WS_OVERLAPPEDWINDOW;
      dwExStyle := WS_EX_WINDOWEDGE;        // Border with a raised edge
    end;
  end;

  // Attempt to create the actual window
  result := CreateWindowEx(dwExStyle,      // Extended window styles
                          WND_CLASS,       // Class name
                          PChar(Titre),   // Window title (caption)
                          dwStyle,        // Window styles
                          X, Y,           // Window position
                          Largeur, Hauteur,  // Size of window
                          hParent,        // parent window
                          0,              // No menu
                          h_Instance,     // Instance
                          nil);           // Pass nothing to WM_CREATE
  if result = 0 then
  begin
    DetruireFenetreGL(0,PleinEcran);                // Undo all the settings we've changed
    MessageBox(0, 'CreateWindowEx() a échoué !', 'GFX', MB_OK or MB_ICONERROR);
    Exit;
  end;

  // Try to get a device context
  h_DC := GetDC(result);
  if (h_DC = 0) then
  begin
    DetruireFenetreGL(result,PleinEcran);
    MessageBox(0, 'Unable to get a device context!', 'Error', MB_OK or MB_ICONERROR);
    Result := 0;
    Exit;
  end;

  // Settings for the OpenGL window
  with pfd do
  begin
    nSize           := SizeOf(TPIXELFORMATDESCRIPTOR); // Size Of This Pixel Format Descriptor
    nVersion        := 1;                    // The version of this data structure
    dwFlags         := PFD_DRAW_TO_WINDOW    // Buffer supports drawing to window
                       or PFD_SUPPORT_OPENGL // Buffer supports OpenGL drawing
                       or PFD_DOUBLEBUFFER;  // Supports double buffering
    iPixelType      := PFD_TYPE_RGBA;        // RGBA color format
    cColorBits      := ProfCouleur;           // OpenGL color depth
    cRedBits        := 0;                    // Number of red bitplanes
    cRedShift       := 0;                    // Shift count for red bitplanes
    cGreenBits      := 0;                    // Number of green bitplanes
    cGreenShift     := 0;                    // Shift count for green bitplanes
    cBlueBits       := 0;                    // Number of blue bitplanes
    cBlueShift      := 0;                    // Shift count for blue bitplanes
    cAlphaBits      := 0;                    // alpha
    cAlphaShift     := 0;                    // Not supported
    cAccumBits      := 0;                   // no accum buffer
    cAccumRedBits   := 0;                    // Number of red bits in a-buffer
    cAccumGreenBits := 0;                    // Number of green bits in a-buffer
    cAccumBlueBits  := 0;                    // Number of blue bits in a-buffer
    cAccumAlphaBits := 0;                    // Number of alpha bits in a-buffer
    cDepthBits      := 32;                   // Specifies the depth of the depth buffer
    cStencilBits    := 8;                    // Turn off stencil buffer
    cAuxBuffers     := 0;                    // Not supported
    iLayerType      := PFD_MAIN_PLANE;       // Ignored
    bReserved       := 0;                    // Number of overlay and underlay planes
    dwLayerMask     := 0;                    // Ignored
    dwVisibleMask   := 0;                    // Transparent color of underlay plane
    dwDamageMask    := 0;                     // Ignored
  end;

  PixelFormat := ChoosePixelFormat(h_DC, @pfd);
  if (PixelFormat = 0) then
  begin
    DetruireFenetreGL(result,PleinEcran);
    MessageBox(0, 'Unable to find a suitable pixel format', 'Error', MB_OK or MB_ICONERROR);
    Result := 0;
    Exit;
  end;

  // pixel format
  if (not SetPixelFormat(h_DC, PixelFormat, @pfd)) then
  begin
    DetruireFenetreGL(result,PleinEcran);
    MessageBox(0, 'Unable to set the pixel format', 'Error', MB_OK or MB_ICONERROR);
    Result := 0;
    Exit;
  end;

  describepixelformat(h_DC, PixelFormat, sizeof(pfd), pfd);

  ShowWindow(result, SW_SHOW);
//  SetForegroundWindow(result);
//  SetFocus(result);
end;



procedure CreerRC(fenetreGL:HWND; pleinecran:boolean);
begin
  // rendering context
  h_RC := wglCreateContext(h_DC);
  if (h_RC = 0) then
  begin
    DetruireFenetreGL(fenetreGL,PleinEcran);
    MessageBox(0, 'Unable to create an OpenGL rendering context', 'Error', MB_OK or MB_ICONERROR);
    Exit;
  end;

  if (not wglMakeCurrent(h_DC, h_RC)) then
  begin
    DetruireFenetreGL(fenetreGL,PleinEcran);
    MessageBox(0, 'Unable to activate OpenGL rendering context', 'Error', MB_OK or MB_ICONERROR);
    Exit;
  end;
end;






procedure glColor1ub(lum:byte);
begin
    glColor3ub(lum, lum, lum);
end;


procedure NormalizePlane(var plane:TPlane);
var  t : single;
begin
  t := sqrt(plane[0]*plane[0] + plane[1]*plane[1] + plane[2]*plane[2] + plane[3]*plane[3]);
  plane[0] := plane[0] / t;
  plane[1] := plane[1] / t;
  plane[2] := plane[2] / t;
  plane[3] := plane[3] / t;
end;

procedure TCamera.calc_frustum();
begin
   //Multiply the two matrices, modelview and projection to get the clip matrix
   clip[ 0] := mat_model[ 0] * mat_proj[ 0] + mat_model[ 1] * mat_proj[ 4] + mat_model[ 2] * mat_proj[ 8] + mat_model[ 3] * mat_proj[12];
   clip[ 1] := mat_model[ 0] * mat_proj[ 1] + mat_model[ 1] * mat_proj[ 5] + mat_model[ 2] * mat_proj[ 9] + mat_model[ 3] * mat_proj[13];
   clip[ 2] := mat_model[ 0] * mat_proj[ 2] + mat_model[ 1] * mat_proj[ 6] + mat_model[ 2] * mat_proj[10] + mat_model[ 3] * mat_proj[14];
   clip[ 3] := mat_model[ 0] * mat_proj[ 3] + mat_model[ 1] * mat_proj[ 7] + mat_model[ 2] * mat_proj[11] + mat_model[ 3] * mat_proj[15];

   clip[ 4] := mat_model[ 4] * mat_proj[ 0] + mat_model[ 5] * mat_proj[ 4] + mat_model[ 6] * mat_proj[ 8] + mat_model[ 7] * mat_proj[12];
   clip[ 5] := mat_model[ 4] * mat_proj[ 1] + mat_model[ 5] * mat_proj[ 5] + mat_model[ 6] * mat_proj[ 9] + mat_model[ 7] * mat_proj[13];
   clip[ 6] := mat_model[ 4] * mat_proj[ 2] + mat_model[ 5] * mat_proj[ 6] + mat_model[ 6] * mat_proj[10] + mat_model[ 7] * mat_proj[14];
   clip[ 7] := mat_model[ 4] * mat_proj[ 3] + mat_model[ 5] * mat_proj[ 7] + mat_model[ 6] * mat_proj[11] + mat_model[ 7] * mat_proj[15];

   clip[ 8] := mat_model[ 8] * mat_proj[ 0] + mat_model[ 9] * mat_proj[ 4] + mat_model[10] * mat_proj[ 8] + mat_model[11] * mat_proj[12];
   clip[ 9] := mat_model[ 8] * mat_proj[ 1] + mat_model[ 9] * mat_proj[ 5] + mat_model[10] * mat_proj[ 9] + mat_model[11] * mat_proj[13];
   clip[10] := mat_model[ 8] * mat_proj[ 2] + mat_model[ 9] * mat_proj[ 6] + mat_model[10] * mat_proj[10] + mat_model[11] * mat_proj[14];
   clip[11] := mat_model[ 8] * mat_proj[ 3] + mat_model[ 9] * mat_proj[ 7] + mat_model[10] * mat_proj[11] + mat_model[11] * mat_proj[15];

   clip[12] := mat_model[12] * mat_proj[ 0] + mat_model[13] * mat_proj[ 4] + mat_model[14] * mat_proj[ 8] + mat_model[15] * mat_proj[12];
   clip[13] := mat_model[12] * mat_proj[ 1] + mat_model[13] * mat_proj[ 5] + mat_model[14] * mat_proj[ 9] + mat_model[15] * mat_proj[13];
   clip[14] := mat_model[12] * mat_proj[ 2] + mat_model[13] * mat_proj[ 6] + mat_model[14] * mat_proj[10] + mat_model[15] * mat_proj[14];
   clip[15] := mat_model[12] * mat_proj[ 3] + mat_model[13] * mat_proj[ 7] + mat_model[14] * mat_proj[11] + mat_model[15] * mat_proj[15];

   //Get the RIGHT clipping plane
   fFrustum[frustum_RIGHT][0] := clip[ 3] - clip[ 0];
   fFrustum[frustum_RIGHT][1] := clip[ 7] - clip[ 4];
   fFrustum[frustum_RIGHT][2] := clip[11] - clip[ 8];
   fFrustum[frustum_RIGHT][3] := clip[15] - clip[12];
   //...and normalize it
   NormalizePlane(fFrustum[frustum_RIGHT]);

   // LEFT
   fFrustum[frustum_LEFT][0] := clip[ 3] + clip[ 0];
   fFrustum[frustum_LEFT][1] := clip[ 7] + clip[ 4];
   fFrustum[frustum_LEFT][2] := clip[11] + clip[ 8];
   fFrustum[frustum_LEFT][3] := clip[15] + clip[12];
   NormalizePlane(fFrustum[frustum_LEFT]);

   // BOTTOM
   fFrustum[frustum_BOTTOM][0] := clip[ 3] + clip[ 1];
   fFrustum[frustum_BOTTOM][1] := clip[ 7] + clip[ 5];
   fFrustum[frustum_BOTTOM][2] := clip[11] + clip[ 9];
   fFrustum[frustum_BOTTOM][3] := clip[15] + clip[13];
   NormalizePlane(fFrustum[frustum_BOTTOM]);

   // TOP
   fFrustum[frustum_TOP][0] := clip[ 3] - clip[ 1];
   fFrustum[frustum_TOP][1] := clip[ 7] - clip[ 5];
   fFrustum[frustum_TOP][2] := clip[11] - clip[ 9];
   fFrustum[frustum_TOP][3] := clip[15] - clip[13];
   NormalizePlane(fFrustum[frustum_TOP]);

   // FAR
   fFrustum[frustum_FAR][0] := clip[ 3] - clip[ 2];
   fFrustum[frustum_FAR][1] := clip[ 7] - clip[ 6];
   fFrustum[frustum_FAR][2] := clip[11] - clip[10];
   fFrustum[frustum_FAR][3] := clip[15] - clip[14];
   NormalizePlane(fFrustum[frustum_FAR]);

   // NEAR
   fFrustum[frustum_NEAR][0] := clip[ 3] + clip[ 2];
   fFrustum[frustum_NEAR][1] := clip[ 7] + clip[ 6];
   fFrustum[frustum_NEAR][2] := clip[11] + clip[10];
   fFrustum[frustum_NEAR][3] := clip[15] + clip[14];
   NormalizePlane(fFrustum[frustum_NEAR]);

end;


//function TCamera.point_in_frustum(x, y, z : single) : boolean;
function TCamera.point_in_frustum(pt:TVector3f; size:single) : boolean;
var
  p : byte;
begin
  result := false;

  p := 6;
  while(p > 0) do begin
    p := p-1;
    if(fFrustum[p][0]*pt[0] + fFrustum[p][1]*pt[1] + fFrustum[p][2]*pt[2] + fFrustum[p][3] <= -size)
    then exit;
  end;

  result := true;
end;


function TCamera.point_in_frustum(x, y, z, size : single) : boolean;
var
  p : byte;
begin
  result := false;

  p := 6;
  while(p > 0) do begin
    p := p-1;
    if(fFrustum[p][0]*x + fFrustum[p][1]*y + fFrustum[p][2]*z + fFrustum[p][3] <= -size)
    then exit;
  end;

  result := true;
end;




end.
