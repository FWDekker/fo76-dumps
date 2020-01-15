unit ExportTabularGLOB;

uses ExportCore,
     ExportTabularCore;


var ExportTabularGLOB_outputLines: TStringList;


function initialize: Integer;
begin
    ExportTabularGLOB_outputLines := TStringList.create();
    ExportTabularGLOB_outputLines.add('"File", "Form ID", "Editor ID", "Value"');
end;

function canProcess(e: IInterface): Boolean;
begin
    result := signature(e) = 'GLOB';
end;

function process(glob: IInterface): Integer;
begin
    if not canProcess(glob) then begin
        addMessage('Warning: ' + name(glob) + ' is not a GLOB. Entry was ignored.');
        exit;
    end;

    ExportTabularGLOB_outputLines.add(
          escapeCsvString(getFileName(getFile(glob))) + ', '
        + escapeCsvString(stringFormID(glob)) + ', '
        + escapeCsvString(evBySign(glob, 'EDID')) + ', '
        + evBySign(glob, 'FLTV')
    );
end;

function finalize: Integer;
begin
    createDir('dumps/');
    ExportTabularGLOB_outputLines.saveToFile('dumps/GLOB.csv');
    ExportTabularGLOB_outputLines.free();
end;


end.
