unit ExportTabularIDs;

uses ExportCore,
     ExportTabularCore,
     ExportFlatList,
     ExportLargeFile;


var ExportTabularIDs_outputLines: TStringList;
var ExportTabularIDs_filePartSize: Integer;


function initialize: Integer;
begin
    ExportTabularIDs_outputLines := TStringList.create();
    ExportTabularIDs_filePartSize := 500000;

    createDir('dumps/');
    clearLargeFiles('dumps/IDs.csv');

    appendLargeFile('dumps/IDs.csv', ExportTabularIDs_outputLines, ExportTabularIDs_filePartSize,
            '"File"'      // Name of the originating ESM
        + ', "Signature"' // Signature
        + ', "Form ID"'   // Form ID
        + ', "Editor ID"' // Editor ID
        + ', "Name"'      // Full name
        + ', "Keywords"'  // Sorted JSON array of keywords. Each keyword is represented by its editor ID
    );
end;

function canProcess(e: IInterface): Boolean;
begin
    result := true;
end;

function process(e: IInterface): Integer;
begin
    appendLargeFile('dumps/IDs.csv', ExportTabularIDs_outputLines, ExportTabularIDs_filePartSize,
          escapeCsvString(getFileName(getFile(e))) + ', '
        + escapeCsvString(signature(e)) + ', '
        + escapeCsvString(stringFormID(e)) + ', '
        + escapeCsvString(evBySign(e, 'EDID')) + ', '
        + escapeCsvString(evBySign(e, 'FULL')) + ', '
        + escapeCsvString(getFlatKeywordList(e))
    );
end;

function finalize: Integer;
begin
    flushLargeFile('dumps/IDs.csv', ExportTabularIDs_outputLines);
    freeLargeFile(ExportTabularIDs_outputLines);
end;


end.
