(**
 * Utility for exporting very large files into multiple parts.
 *)
unit ExportLargeFile;



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


end.
