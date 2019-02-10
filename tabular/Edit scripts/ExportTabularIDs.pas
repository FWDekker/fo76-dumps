unit ExportTabularIDs;

uses ExportCore,
     ExportTabularCore;


var outputLines: TStringList;


function Initialize: integer;
begin
    outputLines := TStringList.Create;
    outputLines.Add('"Signature", "Form ID", "Editor ID", "Name"');
end;

function Process(e: IInterface): integer;
begin
    outputLines.Add(
        EscapeCsvString(StringFormID(e)) + ', ' +
        EscapeCsvString(StringFormID(e)) + ', ' +
        EscapeCsvString(evBySignature(e, 'EDID')) + ', ' +
        EscapeCsvString(evBySignature(e, 'FULL'))
    );
end;

function Finalize: integer;
begin
    CreateDir('dumps/');
    outputLines.SaveToFile('dumps/IDs.csv');
end;


end.
