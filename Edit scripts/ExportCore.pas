(**
 * A collection of functions shared between the different export types.
 *)
unit ExportCore;



(***
 *
 * Shorthands for commonly used functions.
 *
 **)

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
 * @param e  the record to return the form ID of
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
 **)

(**
 * Returns `true` iff [e] is referenced by a record with signature [sig].
 *
 * @param e    the element to check for references
 * @param sig  the signature to check
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
 * Error and warning management.
 *
 **)
var ExportCore_warnings: TStringList;
var ExportCore_errors: TStringList;

(**
 * Initializes error and warning management if this has not happened yet.
 *)
procedure _errorInit();
begin
    if not assigned(ExportCore_warnings) then begin
        ExportCore_warnings := TStringList.create();
    end;
    if not assigned(ExportCore_errors) then begin
        ExportCore_errors := TStringList.create();
    end;
end;

(**
 * Generates and displays a warning message.
 *
 * @param message  the warning message to display
 * @return the warning message to display inside dumps
 *)
function addWarning(message: String): String;
begin
    addMessage('Warning: ' + message);
    result := '';

    _errorInit();
    ExportCore_warnings.add(message);
end;

(**
 * Generates and displays an error message.
 *
 * @param message  the error message to display
 * @return the error message to display inside dumps
 *)
function addError(message: String): String;
begin
    addMessage('Error: ' + message);
    result := '<! {{DUMP ERROR}}: ' + upperCase(message) + ' >';

    _errorInit();
    ExportCore_errors.add(message);
end;

(**
 * Returns a brief summary of the warnings and errors that have been generated.
 *
 * @param full  whether to include all generated messages and warnings
 * @return a brief summary of the warnings and errors that have been generated
 *)
function errorStats(full: Boolean): String;
begin
    _errorInit();

    result :=
        'Generated ' + intToStr(ExportCore_warnings.count) + ' warning(s) and ' +
        intToStr(ExportCore_errors.count) + ' error(s).';

    if full and ((ExportCore_warnings.count > 0) or (ExportCore_errors.count > 0)) then begin
        result := result +
            #10 + #10 +
            '# Warnings' + #10 + ExportCore_warnings.text +
            #10 +
            '# Errors' + #10 + ExportCore_errors.text;
    end;
end;



(***
 *
 * Generic utility functions.
 *
 **)

(**
 * Repeats [text] [amount] times.
 *
 * @param text    the text to repeat
 * @param amount  the number of times to repeat [text]
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
 * @param c  the character to prepend
 * @param s  the string to prepend to
 * @param n  the desired string length
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
 * @param c  the character to append
 * @param s  the string to append to
 * @param n  the desired string length
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
 * Returns an empty string if the given string is empty, or surrounds it with the given prefix and suffix otherwise.
 *
 * @param string  the string to surround with the prefix and suffix
 * @param prefix  the string to put in front
 * @param suffix  the string to put at the end
 * @return an empty string if the given string is empty, or surrounds it with the given prefix and suffix otherwise
 *)
function surroundIfNotEmpty(string: String; prefix: String; suffix: String): String;
begin
    result := ifThen(string = '', '', prefix + string + suffix);
end;

(**
 * Converts a truthy boolean to 'True' and a falsy boolean to 'False'.
 *
 * @param bool  the bool to convert to a string
 * @return 'True' if [bool] is true and 'False' if [bool] is false
 *)
function boolToStr(bool: Boolean): String;
begin
    result := ifThen(bool, 'True', 'False');
end;

(**
 * Parses the given string to a float, rounds it, and turns that into a string.
 *
 * If the given string is not a float, the given string is returned.
 *
 * @param float  the float to parse and round
 * @return a string describing the rounded integer
 *)
function parseFloatToInt(float: String): String;
begin
    if float = '' then begin
        result := '';
        exit;
    end;

    try
        result := intToStr(round(strToFloat(float)));
    except
        result := float;
    end;
end;


end.
