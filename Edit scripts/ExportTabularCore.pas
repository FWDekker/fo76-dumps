(**
 * A collection of functions used when creating tabular dumps.
 *)
unit ExportTabularCore;


(**
 * Escapes [text] by escaping quotes and then surrounding it with quotes.
 *
 * @param text  the text to escape
 * @return a CSV-escaped version of [text]
 *)
function escapeCsvString(text: String): String;
begin
    result := '"' + stringReplace(text, '"', '""', [rfReplaceAll]) + '"';
end;


end.
