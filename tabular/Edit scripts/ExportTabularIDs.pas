unit ExportTabularIDs;

uses ExportCore,
     ExportTabularCore;


var outputLines: TStringList;
var filePartSize: integer;


function Initialize: integer;
begin
    outputLines := TStringList.Create;
    filePartSize := 500000;

    CreateDir('dumps/');
    ClearLargeFiles('dumps/IDs.csv');

    AppendLargeFile('dumps/IDs.csv', outputLines, filePartSize, '"Signature", "Form ID", "Editor ID", "Name"');
end;

function Process(e: IInterface): integer;
begin
    AppendLargeFile('dumps/IDs.csv', outputLines, filePartSize,
        EscapeCsvString(Signature(e)) + ', ' +
        EscapeCsvString(StringFormID(e)) + ', ' +
        EscapeCsvString(evBySignature(e, 'EDID')) + ', ' +
        EscapeCsvString(evBySignature(e, 'FULL'))
    );
end;

function Finalize: integer;
begin
    FlushLargeFile('dumps/IDs.csv', outputLines);
end;


end.
