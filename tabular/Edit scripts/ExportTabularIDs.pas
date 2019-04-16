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

    AppendLargeFile('dumps/IDs.csv', outputLines, filePartSize,
        '"Signature", "Form ID", "Editor ID", "Name", "Keywords"'
    );
end;

function Process(e: IInterface): integer;
begin
    AppendLargeFile('dumps/IDs.csv', outputLines, filePartSize,
        EscapeCsvString(Signature(e)) + ', ' +
        EscapeCsvString(StringFormID(e)) + ', ' +
        EscapeCsvString(evBySignature(e, 'EDID')) + ', ' +
        EscapeCsvString(evBySignature(e, 'FULL')) + ', ' +
        EscapeCsvString(GetFlatKeywordList(e))
    );
end;

function Finalize: integer;
begin
    FlushLargeFile('dumps/IDs.csv', outputLines);
end;


(**
 * Returns the keywords of [e] as a comma-separated list of editor IDs.
 *
 * @param e the element to return the keywords of
 * @return the keywords of [e] as a comma-separated list of editor IDs
 *)
function GetFlatKeywordList(e: IInterface): string;
var i: integer;
    keywords: IInterface;
begin
    Result := ',';

    keywords := eBySignature(eByPath(e, 'Keywords'), 'KWDA');
    for i := 0 to eCount(keywords) - 1 do
    begin
        Result := Result + evBySignature(LinksTo(eByIndex(keywords, i)), 'EDID') + ',';
    end;
end;


end.
