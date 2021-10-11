program opengl_window;

////////////////////////////////////////////////////
//                                                //
//      ///           ///////      //////////     //
//     ///          ///             ///    ///    //
//    ///           //////         ///      //    //
//   ///               ///        ///     ///     //
//  //////// //  ///////   //  ////////////  //   //
//                                                //
////////////////////////////////////////////////////
//          Projet sup promo 2008 [sup²]          //
////////////////////////////////////////////////////

uses
  Forms,
  gui in 'gui.pas' {frmMain},
  GFX in 'GFX.pas',
  GLu in 'GLu.pas',
  GL in 'GL.pas',
  GLext in 'GLext.pas',
  Textures in 'Textures.pas',
  input in 'input.pas',
  Geometry in 'Geometry.pas',
  glUtils in 'glUtils.pas',
  glBezier in 'libs\glBezier.pas';

{$R *.res}

begin
  {$I+}
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
