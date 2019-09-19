unit ExportTabularGLOB;

uses ExportCore,
     ExportTabularCore;


var outputLines: TStringList;


function initialize: Integer;
begin
    outputLines := TStringList.create;
    outputLines.add('"File", "Form ID", "Editor ID", "Value"');
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

    outputLines.add(
        escapeCsvString(getFileName(getFile(glob))) + ', ' +
        escapeCsvString(stringFormID(glob)) + ', ' +
        escapeCsvString(evBySignature(glob, 'EDID')) + ', ' +
        evBySignature(glob, 'FLTV')
    );
end;

function finalize: Integer;
begin
    createDir('dumps/');
    outputLines.saveToFile('dumps/GLOB.csv');
end;


end.
