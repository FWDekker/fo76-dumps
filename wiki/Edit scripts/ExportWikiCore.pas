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
function CreateWikiHeader(text: string; depth: integer): string;
begin
    Result := RepeatString('=', 2 + depth) + text + RepeatString('=', 2 + depth);
end;

(**
 * Escapes a selection of HTML symbols.
 *
 * @param text the text to escape
 * @return an HTML-escaped version of [text]
 *)
function EscapeHTML(text: string): String;
begin
    Result := text;
    Result := StringReplace(Result, '<', '&lt;', [rfReplaceAll]);
    Result := StringReplace(Result, '>', '&gt;', [rfReplaceAll]);
end;

(**
 * Escapes a selection of MediaWiki symbols, including those escaped by [EscapeHTML].
 *
 * @param text the text to escape
 * @return a MediaWiki-escaped version of [text]
 *)
function EscapeWiki(text: String): String;
begin
    Result := EscapeHTML(text);
    Result := StringReplace(Result, '{', '&#123;', [rfReplaceAll]);
    Result := StringReplace(Result, '|', '&#124;', [rfReplaceAll]);
    Result := StringReplace(Result, '}', '&#125;', [rfReplaceAll]);
end;


end.
