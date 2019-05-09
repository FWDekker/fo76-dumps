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
function EscapeCsvString(text: string): string;
begin
    Result := text;
    Result := StringReplace(Result, '"', '\"', [rfReplaceAll]);
    Result := '"' + text + '"';
end;


end.
