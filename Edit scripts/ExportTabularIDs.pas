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
        '"Signature", "Form ID", "Editor ID", "Name", "Keywords"'
    );
end;

function process(e: IInterface): Integer;
begin
    appendLargeFile('dumps/IDs.csv', outputLines, filePartSize,
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


(**
 * Returns the keywords of [e] as a comma-separated list of editor IDs.
 *
 * @param e the element to return the keywords of
 * @return the keywords of [e] as a comma-separated list of editor IDs
 *)
function getFlatKeywordList(e: IInterface): String;
var i: Integer;
    keywords: IInterface;
begin
    result := ',';

    keywords := eBySignature(eByPath(e, 'Keywords'), 'KWDA');
    for i := 0 to eCount(keywords) - 1 do
    begin
        result := result + evBySignature(linksTo(eByIndex(keywords, i)), 'EDID') + ',';
    end;
end;


end.
