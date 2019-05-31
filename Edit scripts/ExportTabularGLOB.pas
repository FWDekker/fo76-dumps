unit ExportTabularGLOB;

uses ExportCore,
     ExportTabularCore;


var outputLines: TStringList;


function initialize: Integer;
begin
    outputLines := TStringList.create;
    outputLines.add('"Form ID", "Editor ID", "Value"');
end;

function process(e: IInterface): Integer;
begin
    if signature(e) <> 'GLOB' then begin
        addMessage('Warning: ' + name(e) + ' is not a GLOB. Entry was ignored.');
        exit;
    end;

    outputLines.add(
        escapeCsvString(stringFormID(e)) + ', ' +
        escapeCsvString(evBySignature(e, 'EDID')) + ', ' +
        evBySignature(e, 'FLTV')
    );
end;

function finalize: Integer;
begin
    createDir('dumps/');
    outputLines.saveToFile('dumps/GLOB.csv');
end;


end.
