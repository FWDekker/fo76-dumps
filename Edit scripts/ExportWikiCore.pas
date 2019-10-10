(**
 * A collection of functions used when creating wiki dumps.
 *)
unit ExportWikiCore;

uses ExportCore;


(**
 * Returns a wiki-style section header.
 *
 * @param text  the name of the section header
 * @param depth the depth of the section header, where 0 is the default level
 * @return a wiki-style section header
 *)
function createWikiHeader(text: String; depth: Integer): String;
begin
    result := repeatString('=', 2 + depth) + text + repeatString('=', 2 + depth);
end;

(**
 * Escapes a selection of HTML symbols.
 *
 * @param text the text to escape
 * @return an HTML-escaped version of [text]
 *)
function escapeHTML(text: String): String;
begin
    result := text;
    result := stringReplace(result, '<', '&lt;', [rfReplaceAll]);
    result := stringReplace(result, '>', '&gt;', [rfReplaceAll]);
end;

(**
 * Escapes a selection of MediaWiki symbols after applying `escapeHTML`.
 *
 * @param text the text to escape
 * @return a MediaWiki-escaped version of [text]
 *)
function escapeWiki(text: String): String;
begin
    result := text;
    result := escapeHTML(text);
    result := stringReplace(result, '{', '&#123;', [rfReplaceAll]);
    result := stringReplace(result, '|', '&#124;', [rfReplaceAll]);
    result := stringReplace(result, '}', '&#125;', [rfReplaceAll]);
end;


end.
