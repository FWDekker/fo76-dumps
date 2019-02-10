unit ExportTabularGLOB;

uses ExportTabularCore;


var outputLines: TStringList;


function Initialize: integer;
begin
    outputLines := TStringList.Create;
    outputLines.Add('"Form ID", "Editor ID", "Value"');
end;

function Process(e: IInterface): integer;
begin
    outputLines.Add(
        EscapeCsvString(LowerCase(IntToHex(FormID(e), 8))) + ', ' +
        EscapeCsvString(GetEditValue(ElementBySignature(e, 'EDID'))) + ', ' +
        GetEditValue(ElementBySignature(e, 'FLTV'))
    );
end;

function Finalize: integer;
begin
    CreateDir('dumps/');
    outputLines.SaveToFile('dumps/GLOB.csv');
end;


end.
