unit ExportTabularIDs;

uses ExportCore,
     ExportTabularCore;


var ExportTabularIDs_outputLines: TStringList;
var ExportTabularIDs_filePartSize: Integer;


function initialize: Integer;
begin
    ExportTabularIDs_outputLines := TStringList.create;
    ExportTabularIDs_filePartSize := 500000;

    createDir('dumps/');
    clearLargeFiles('dumps/IDs.csv');

    appendLargeFile('dumps/IDs.csv', ExportTabularIDs_outputLines, ExportTabularIDs_filePartSize,
        '"File", "Signature", "Form ID", "Editor ID", "Name", "Keywords"'
    );
end;

function canProcess(e: IInterface): Boolean;
begin
    result := true;
end;

function process(e: IInterface): Integer;
begin
    appendLargeFile('dumps/IDs.csv', ExportTabularIDs_outputLines, ExportTabularIDs_filePartSize,
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
    flushLargeFile('dumps/IDs.csv', ExportTabularIDs_outputLines);
end;


end.
