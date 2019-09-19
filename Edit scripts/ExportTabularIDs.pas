unit ExportTabularIDs;

uses ExportCore,
     ExportTabularCore;


var outputLines: TStringList;
var filePartSize: Integer;


function initialize: Integer;
begin
    outputLines := TStringList.create;
    filePartSize := 500000;

    createDir('dumps/');
    clearLargeFiles('dumps/IDs.csv');

    appendLargeFile('dumps/IDs.csv', outputLines, filePartSize,
        '"File", "Signature", "Form ID", "Editor ID", "Name", "Keywords"'
    );
end;

function canProcess(e: IInterface): Boolean;
begin
    result := true;
end;

function process(e: IInterface): Integer;
begin
    appendLargeFile('dumps/IDs.csv', outputLines, filePartSize,
        escapeCsvString(getFileName(getFile(e))) + ', ' +
        escapeCsvString(signature(e)) + ', ' +
        escapeCsvString(stringFormID(e)) + ', ' +
        escapeCsvString(evBySignature(e, 'EDID')) + ', ' +
        escapeCsvString(evBySignature(e, 'FULL')) + ', ' +
        escapeCsvString(getFlatKeywordList(e))
    );
end;

function finalize: Integer;
begin
    flushLargeFile('dumps/IDs.csv', outputLines);
end;


end.
