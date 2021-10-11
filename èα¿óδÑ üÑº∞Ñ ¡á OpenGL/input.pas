unit input;

interface

type
  TMouse = class
  public
    x, y : integer;
    px,py,pz,pt: single;
    rx,ry,rz,rt: single;
    moved : boolean;
    procedure project(z : single);
  end;


procedure do_input(dticks:cardinal);


var
  mouse : TMouse;



implementation

Uses sysutils, windows, GFX, gui, math, geometry, GL, GLu, glBezier;




function touche_pressee(c : char) : boolean; overload;
begin
    result := GetAsyncKeyState(Integer(c)) < 0;
end;

function touche_pressee(virtkey : integer) : boolean; overload;
begin
    result := GetAsyncKeyState(virtkey) < 0;
end;

function touche_up(virtkey : integer) : boolean; overload;
begin
    result := (GetAsyncKeyState(virtkey) and 1) <> 0;
end;



procedure do_input(dticks:cardinal);
var
  k : single;
begin
  if touche_pressee(VK_RETURN) then
    bezier.RandBounce;

  if(touche_pressee('Q')) then begin
    camera.moved := true;
    camera.rot.y := (camera.rot.y + dticks*0.064);
    if(camera.rot.y >= 360) then camera.rot.y := camera.rot.y - 360;
  end;

  if(touche_pressee('D')) then begin
    camera.moved := true;
    camera.rot.y := (camera.rot.y - dticks*0.064);
    if (camera.rot.y < 0) then camera.rot.y := camera.rot.y + 360;
  end;

  if(touche_pressee(VK_SPACE)) then begin
    camera.pos.z := camera.pos.z + dticks * 0.004;
    camera.moved := true;
  end;

  if(touche_pressee(VK_CONTROL)) then begin
    camera.pos.z := camera.pos.z - dticks * 0.004;
    camera.moved := true;
  end;

  if(touche_pressee('Z'))   then    k :=-0.014*dticks
  else if(touche_pressee('S')) then k :=+0.014*dticks
  else exit;

  camera.pos.x := camera.pos.x + camera.mat_model[2] * k;
  camera.pos.y := camera.pos.y + camera.mat_model[6] * k;
  camera.pos.z := camera.pos.z + camera.mat_model[10] * k;
  camera.moved := true;
end;



procedure TMouse.project(z : single);
var
  p : array [0..2] of double;
  k : double;
begin
  if( gluUnProject( mouse.x, viewport[3]-mouse.y,0.1,
                    T16dArray(camera.mat_model), T16dArray(camera.mat_proj), TViewportArray(viewport),
                    @p[0], @p[1], @p[2])= GL_FALSE) then exit;

  if(camera.pos.z - z < 0) then begin
      if((p[2]-camera.pos.z) < 0.0000001) then exit;
  end
  else if(camera.pos.z - z > 0) then begin
      if((p[2]-camera.pos.z) > 0.0000001) then exit;
  end
  else exit;

  k := (camera.pos.z - z) / (p[2]-camera.pos.z);
  
  mouse.rx := camera.pos.x - k*(p[0]-camera.pos.x);
  mouse.ry := camera.pos.y - k*(p[1]-camera.pos.y);
  mouse.px := round(mouse.rx);
  mouse.py := round(mouse.ry);
end;



begin
  mouse := TMouse.Create;
  mouse.pz :=  0;
  mouse.rz := -3;
  mouse.pt :=  1;
  mouse.rt :=  1;

end.
