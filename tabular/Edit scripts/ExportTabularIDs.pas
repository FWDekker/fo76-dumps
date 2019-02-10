unit ExportTabularIDs;

uses ExportTabularCore;


var outputLines: TStringList;


function Initialize: integer;
begin
    outputLines := TStringList.Create;
    outputLines.Add('"Signature", "Form ID", "Editor ID", "Name"');
end;

function Process(e: IInterface): integer;
begin
    outputLines.Add(
        EscapeCsvString(Signature(e)) + ', ' +
        EscapeCsvString(LowerCase(IntToHex(FormID(e), 8))) + ', ' +
        EscapeCsvString(GetEditValue(ElementBySignature(e, 'EDID'))) + ', ' +
        EscapeCsvString(GetEditValue(ElementBySignature(e, 'FULL')))
    );
end;

function Finalize: integer;
begin
    CreateDir('dumps/');
    outputLines.SaveToFile('dumps/IDs.csv');
end;


end.
