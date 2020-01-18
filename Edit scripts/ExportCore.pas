(**
 * A collection of functions shared between the different export types.
 *)
unit ExportCore;



(***
 *
 * Shorthands for commonly used functions.
 *
 ***)

(**
 * Shorthand for [getEditValue].
 *)
function gev(e: IwbElement): String;
begin
    result := getEditValue(e);
end;

(**
 * Shorthand for [elementBySignature].
 *)
function eBySign(e: IwbContainer; sig: String): IwbElement;
begin
    result := elementBySignature(e, sig);
end;

(**
 * Shorthand for [elementByPath].
 *)
function eByPath(e: IwbContainer; path: String): IwbElement;
begin
    result := elementByPath(e, path);
end;

(**
 * Shorthand for [elementByName].
 *)
function eByName(e: IwbContainer; nam: String): IwbElement;
begin
    result := elementByName(e, nam);
end;

(**
 * Shorthand for [elementCount].
 *)
function eCount(e: IwbContainer): Integer;
begin
    result := elementCount(e);
end;

(**
 * Shorthand for [elementByIndex].
 *)
function eByIndex(e: IwbContainer; i: Integer): IwbElement;
begin
    result := elementByIndex(e, i);
end;

(**
 * Shorthand for calling [getEditValue] and [elementBySignature].
 *)
function evBySign(e: IInterface; sig: String): String;
begin
    result := gev(eBySign(e, sig));
end;

(**
 * Shorthand for calling [getEditValue] and [elementByPath].
 *)
function evByPath(e: IInterface; path: String): String;
begin
    result := gev(eByPath(e, path));
end;

(**
 * Shorthand for calling [getEditValue] and [elementByName].
 *)
function evByName(e: IInterface; nam: String): String;
begin
    result := gev(eByName(e, nam));
end;

(**
 * Shorthand for calling [getEditValue] and [elementByIndex].
 *)
function evByIndex(e: IInterface; i: Integer): String;
begin
    result := gev(eByIndex(e, i));
end;

(**
 * Shorthand for calling [linksTo] and [elementBySignature].
 *)
function linkBySign(e: IInterface; sig: String): IInterface;
begin
    result := linksTo(eBySign(e, sig));
end;

(**
 * Shorthand for calling [linksTo] and [elementByPath].
 *)
function linkByPath(e: IInterface; path: String): IInterface;
begin
    result := linksTo(eByPath(e, path));
end;

(**
 * Shorthand for calling [linksTo] and [elementByName].
 *)
function linkByName(e: IInterface; nam: String): IInterface;
begin
    result := linksTo(eByName(e, nam));
end;

(**
 * Shorthand for calling [linksTo] and [elementByIndex].
 *)
function linkByIndex(e: IInterface; i: Integer): IInterface;
begin
    result := linksTo(eByIndex(e, i));
end;


(**
 * Returns a lowercase string representation of [e]'s form ID.
 *
 * @param e the record to return the form ID of
 * @return a lowercase string representation of [e]'s form ID
 *)
function stringFormID(e: IInterface): String;
begin
    result := lowerCase(intToHex(formID(e), 8));
end;



(***
 *
 * xEdit utility functions
 *
 ***)

(**
 * Returns `true` iff [e] is referenced by a record with signature [sig].
 *
 * @param e   the element to check for references
 * @param sig the signature to check
 * @return `true` iff [e] is referenced by a record with signature [sig]
 *)
function isReferencedBy(e: IInterface; sig: String): Boolean;
var i: Integer;
begin
    result := false;

    for i := 0 to referencedByCount(e) - 1 do begin
        if signature(referencedByIndex(e, i)) = sig then begin
            result := true;
            exit;
        end;
    end;
end;



(***
 *
 * I/O utility functions.
 *
 ***)

(**
 * Deletes files `[filename].001` through `[filename].999`.
 *
 * @param filename the prefix of the files to delete
 *)
procedure clearLargeFiles(filename: String);
var i: Integer;
begin
    for i := 1 to 999 do begin
        deleteFile(filename + '.' + padLeft('0', intToStr(i), 3));
    end;
end;

(**
 * Appends [text] to [filename] while using [lines] as a buffer to write in chunks of [maxSize] lines.
 *
 * The first chunk is written to `[filename].001`, the second to `[filename].002`, and so on.
 *
 * @param filename the prefix of the file to write to
 * @param lines    the line buffer
 * @param maxSize  the maximum size of a chunk before the buffer should be flushed
 * @param text     the new line to add
 *)
procedure appendLargeFile(filename: String; lines: TStringList; maxSize: Integer; text: String);
begin
    lines.add(text);

    if lines.count >= maxSize then begin
        lines.saveToFile(_findFreeLargeFile(filename));
        lines.clear();
    end;
end;

(**
 * Flushes the line buffer [lines] to a [filename] part even if the buffer is not file.
 *
 * @param filename the prefix of the file to write to
 * @param lines    the line buffer
 * @see appendLargeFile
 *)
procedure flushLargeFile(filename: String; lines: TStringList);
begin
    lines.saveToFile(_findFreeLargeFile(filename));
    lines.clear();
end;

(**
 * Frees the line buffer [lines] from memory.
 *
 * @param lines the line buffer to free
 * @see appendLargeFile
 *)
procedure freeLargeFile(lines: TStringList);
begin
    lines.free();
end;

(**
 * Determines the first filename part that does not exist.
 *
 * @param filename the prefix of the file to find
 * @return the first filename part that does not exist
 * @see appendLargeFile
 *)
function _findFreeLargeFile(filename: String): String;
var i: Integer;
    candidate: String;
begin
    for i := 1 to 999 do begin
        candidate := filename + '.' + padLeft('0', intToStr(i), 3);

        if not fileExists(candidate) then begin
            result := candidate;
            break;
        end;
    end;
end;



(***
 *
 * Generic utility functions.
 *
 ***)

(**
 * Repeats [text] [amount] times.
 *
 * @param text   the text to repeat
 * @param amount the number of times to repeat [text]
 * @return the concatenation of [amount] times [text]
 *)
function repeatString(text: String; amount: Integer): String;
var i: Integer;
begin
    result := '';

    for i := 1 to amount do begin
        result := result + text;
    end;
end;

(**
 * Prepends [c] to [s] until [s] is at least [n] characters long.
 *
 * If [s] is already longer than [n] characters, [s] is returned unchanged.
 *
 * @param c the character to prepend
 * @param s the string to prepend to
 * @param n the desired string length
 * @return a string of at least [n] characters that consists of [s] preceded by copies of [c]
 *)
function padLeft(c: Char; s: String; n: Size): String;
begin
    result := s;

    while length(result) < n do begin
        result := c + result;
    end;
end;

(**
 * Appends [c] to [s] until [s] is at least [n] characters long.
 *
 * If [s] is already longer than [n] characters, [s] is returned unchanged.
 *
 * @param c the character to append
 * @param s the string to append to
 * @param n the desired string length
 * @return a string of at least [n] characters that consists of [s] proceeded by copies of [c]
 *)
function padRight(c: Char; s: String; n: Size): String;
begin
    result := s;

    while length(result) < n do begin
        result := result + c;
    end;
end;

(**
 * Shorthand for `compareStr(a, b) = 0`.
 *)
function strEquals(a: String; b: String): Boolean;
begin
    result := compareStr(a, b) = 0;
end;

(**
 * Converts a truthy boolean to 'True' and a falsy boolean to 'False'.
 *
 * @param bool the bool to convert to a string
 * @return 'True' if [bool] is true and 'False' if [bool] is false
 *)
function boolToStr(bool: Boolean): String;
begin
    result := ifThen(bool, 'True', 'False');
end;

(**
 * Parses the given string to a float, rounds it, and turns that into a string.
 *
 * @param float the float to parse and round
 * @return a string describing the rounded integer
 *)
function parseFloatToInt(float: String): String;
begin
    if float = '' then begin
        result := '';
        exit;
    end;
    result := intToStr(round(strToFloat(float)));
end;


end.
