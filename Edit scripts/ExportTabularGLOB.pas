unit ExportTabularGLOB;

uses ExportCore,
     ExportTabularCore;


var ExportTabularGLOB_outputLines: TStringList;


function initialize(): Integer;
begin
    ExportTabularGLOB_outputLines := TStringList.create();
    ExportTabularGLOB_outputLines.add(
            '"File"'       // Name of the originating ESM
        + ', "Form ID"'    // Form ID
        + ', "Editor ID"'  // Editor ID
        + ', "Value"'      // Value of the global variable
    );
end;

function process(glob: IInterface): Integer;
begin
    if signature(glob) <> 'GLOB' then begin exit; end;

    ExportTabularGLOB_outputLines.add(
          escapeCsvString(getFileName(getFile(glob))) + ', '
        + escapeCsvString(stringFormID(glob)) + ', '
        + escapeCsvString(evBySign(glob, 'EDID')) + ', '
        + evBySign(glob, 'FLTV')
    );
end;

function finalize(): Integer;
begin
    createDir('dumps/');
    ExportTabularGLOB_outputLines.saveToFile('dumps/GLOB.csv');
    ExportTabularGLOB_outputLines.free();
end;


end.
