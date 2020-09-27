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
    result := text;
    result := stringReplace(result, '"', '""', [rfReplaceAll]);
    result := '"' + result + '"';
end;

(**
 * Escapes all double quotes in [text] by putting a backslash in front of them.
 *
 * @param text  the text to escape
 * @return a quote-escaped version of [text]
 *)
function escapeQuotes(text: String): String;
begin
    result := stringReplace(text, '"', '\"', [rfReplaceAll]);
end;


end.
