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
 * Shorthand for [GetEditValue].
 *)
function gev(e: IwbElement): string;
begin
    Result := GetEditValue(e);
end;

(**
 * Shorthand for [ElementBySignature].
 *)
function eBySignature(e: IwbContainer; sig: string): IwbElement;
begin
    Result := ElementBySignature(e, sig);
end;

(**
 * Shorthand for [ElementByPath].
 *)
function eByPath(e: IwbContainer; path: string): IwbElement;
begin
    Result := ElementByPath(e, path);
end;

(**
 * Shorthand for [ElementByName].
 *)
function eByName(e: IwbContainer; nam: string): IwbElement;
begin
    Result := ElementByName(e, nam);
end;

(**
 * Shorthand for [ElementCount].
 *)
function eCount(e: IwbContainer): integer;
begin
    Result := ElementCount(e);
end;

(**
 * Shorthand for [ElementByIndex].
 *)
function eByIndex(e: IwbContainer; i: integer): IwbElement;
begin
    Result := ElementByIndex(e, i);
end;


(**
 * Shorthand for calling [GetEditValue] and [ElementBySignature].
 *
 * @param e   the record to get the edit value from
 * @param sig the signature of the element to return the edit value of
 * @return the edit value of the element with signature [sig] in [e]
 *)
function evBySignature(e: IInterface; sig: string): string;
begin
    Result := gev(eBySignature(e, sig));
end;

(**
 * Shorthand for calling [GetEditValue] and [ElementByPath].
 *
 * @param e    the record to get the edit value from
 * @param path the path of the element to return the edit value of
 * @return the edit value of the element with path [path] in [e]
 *)
function evByPath(e: IInterface; path: string): string;
begin
    Result := gev(eByPath(e, path));
end;


(**
 * Returns a lowercase string representation of [e]'s form ID.
 *
 * @param e the record to return the form ID of
 * @return a lowercase string representation of [e]'s form ID
 *)
function StringFormID(e: IInterface): string;
begin
    Result := LowerCase(IntToHex(FormID(e), 8));
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
function IsReferencedBy(e: IInterface; sig: string): boolean;
var i: integer;
begin
    Result := false;

    for i := 0 to (ReferencedByCount(e) - 1) do
    begin
        if (Signature(ReferencedByIndex(e, i)) = sig) then
        begin
            Result := true;
            Exit;
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
procedure ClearLargeFiles(filename: string);
var i: integer;
begin
    for i := 1 to 999 do
    begin
        DeleteFile(filename + '.' + PadLeft('0', IntToStr(i), 3));
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
procedure AppendLargeFile(filename: string; lines: TStringList; maxSize: integer; text: string);
begin
    lines.Add(text);

    if (lines.Count >= maxSize) then
    begin
        lines.SaveToFile(_FindFreeLargeFile(filename));
        lines.Clear();
    end;
end;

(**
 * Flushes the line buffer [lines] to a [filename] part even if the buffer is not file.
 *
 * @param filename the prefix of the file to write to
 * @param lines    the line buffer
 * @see AppendLargeFile
 *)
procedure FlushLargeFile(filename: string; lines: TStringList);
begin
    lines.SaveToFile(_FindFreeLargeFile(filename));
    lines.Clear();
end;

(**
 * Determines the first filename part that does not exist.
 * 
 * @param filename the prefix of the file to find
 * @return the first filename part that does not exist
 * @see AppendLargeFile
 *)
function _FindFreeLargeFile(filename: string): string;
var i: integer;
    candidate: string;
begin
    for i := 1 to 999 do
    begin
        candidate := filename + '.' + PadLeft('0', IntToStr(i), 3);

        if (not FileExists(candidate)) then
        begin
            Result := candidate;
            Break;
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
function RepeatString(text: string; amount: integer): string;
var i: integer;
begin
	Result := '';

	for i := 1 to amount do begin
		Result := Result + text;
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
function PadLeft(c: char; s: string; n: size): string;
begin
    Result := s;

    while (Length(Result) < n) do
    begin
        Result := c + Result;
    end;
end;


end.
