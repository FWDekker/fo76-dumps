(**
 * A collection of functions used when creating tabular dumps.
 *)
unit ExportTabularCore;


(**
 * Escapes [text] by escaping quotes and then surrounding it with quotes.
 *
 * @param text the text to escape
 * @return a CSV-escaped version of [text]
 *)
function escapeCsvString(text: String): String;
begin
    result := text;
    result := stringReplace(result, '"', '""', [rfReplaceAll]);
    result := '"' + result + '"';
end;

(**
 * Escapes all double quotes in [text] by putting a backslash in front of them.
 *
 * @param text the text to escape
 * @return a quote-escaped version of [text]
 *)
function escapeQuotes(text: String): String;
begin
    result := stringReplace(text, '"', '\"', [rfReplaceAll]);
end;

(**
 * Flattens the string into a JSON array string.
 *
 * @param list the list to convert to a JSON array string
 * @return a JSON-escapes version of [list]
 *)
function listToJson(list: TStringList): String;
var i: Integer;
begin
    if list.count = 0 then begin
        result := '[]';
        exit;
    end;

    result := '"' + list[0] + '"';
    for i := 1 to list.count - 1 do begin
        result := result + ',"' + list[i] + '"';
    end;

    result := '[' + result + ']';
end;


end.
