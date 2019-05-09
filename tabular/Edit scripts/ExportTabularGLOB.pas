unit ExportTabularGLOB;

uses ExportCore,
     ExportTabularCore;


var outputLines: TStringList;


function Initialize: integer;
begin
    outputLines := TStringList.Create;
    outputLines.Add('"Form ID", "Editor ID", "Value"');
end;

function Process(e: IInterface): integer;
begin
    outputLines.Add(
        EscapeCsvString(StringFormID(e)) + ', ' +
        EscapeCsvString(evBySignature(e, 'EDID')) + ', ' +
        evBySignature(e, 'FLTV')
    );
end;

function Finalize: integer;
begin
    CreateDir('dumps/');
    outputLines.SaveToFile('dumps/GLOB.csv');
end;


end.
