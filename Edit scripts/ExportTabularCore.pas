(**
 * A collection of functions used when creating tabular dumps.
 *)
unit ExportTabularCore;


(**
 * Escapes [text] by escaping quotes and then surrounding it with quotes.
 *
 * @param the text to escape
 * @return a CSV-escaped version of [text]
 *)
function escapeCsvString(text: String): String;
begin
    result := text;
    result := stringReplace(result, '"', '\"', [rfReplaceAll]);
    result := '"' + text + '"';
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
    for i := 0 to eCount(keywords) - 1 do begin
        result := result + evBySignature(linksTo(eByIndex(keywords, i)), 'EDID') + ',';
    end;
end;


end.
