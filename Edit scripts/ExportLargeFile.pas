(**
 * Utility for exporting very large files into multiple parts.
 *)
unit ExportLargeFile;



(**
 * Deletes files `[filename].001` through `[filename].999`.
 *
 * @param filename  the prefix of the files to delete
 *)
procedure clearLargeFiles(filename: String);
var i: Integer;
begin
    for i := 1 to 999 do begin
        deleteFile(filename + '.' + padLeft('0', intToStr(i), 3));
    end;
end;

(**
 * Appends [text] to [filename] while using [buffer] to write in chunks of [maxSize] lines.
 *
 * The first chunk is written to `[filename].001`, the second to `[filename].002`, and so on.
 *
 * @param filename  the prefix of the file to write to
 * @param buffer    the line buffer
 * @param size      the current size of the buffer; updated automatically by this function
 * @param maxSize   the maximum size of a chunk in bytes before the buffer should be flushed
 * @param text      the new line to add
 *)
procedure appendLargeFile(filename: String; buffer: TStringList; var size: Integer; maxSize: Integer; text: String);
begin
    buffer.add(text);
    size := size + length(text) + 1;

    if size >= maxSize then begin
        buffer.saveToFile(_findFreeLargeFile(filename));
        buffer.clear();
        size := 0;
    end;
end;

(**
 * Flushes [buffer] to a [filename] part even if the buffer is not full.
 *
 * @param filename  the prefix of the file to write to
 * @param buffer    the line buffer
 * @param size      the current size of the buffer; updated automatically by this function
 * @see appendLargeFile
 *)
procedure flushLargeFile(filename: String; buffer: TStringList; var size: Integer);
begin
    if buffer.count = 0 then begin
        exit;
    end;

    buffer.saveToFile(_findFreeLargeFile(filename));
    buffer.clear();
    size := 0;
end;

(**
 * Frees the line buffer [buffer] from memory.
 *
 * @param buffer  the line buffer to free
 * @see appendLargeFile
 *)
procedure freeLargeFile(buffer: TStringList);
begin
    buffer.free();
end;

(**
 * Determines the first filename part that does not exist.
 *
 * @param filename  the prefix of the file to find
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
