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
function gev(el: IwbElement): String;
begin
    result := getEditValue(el);
end;

(**
 * Shorthand for [elementBySignature].
 *)
function eBySign(el: IwbContainer; sig: String): IwbElement;
begin
    result := elementBySignature(el, sig);
end;

(**
 * Shorthand for [elementByPath].
 *)
function eByPath(el: IwbContainer; path: String): IwbElement;
begin
    result := elementByPath(el, path);
end;

(**
 * Shorthand for [elementByName].
 *)
function eByName(el: IwbContainer; nam: String): IwbElement;
begin
    result := elementByName(el, nam);
end;

(**
 * Shorthand for [elementCount].
 *)
function eCount(el: IwbContainer): Integer;
begin
    result := elementCount(el);
end;

(**
 * Shorthand for [elementByIndex].
 *)
function eByIndex(el: IwbContainer; i: Integer): IwbElement;
begin
    result := elementByIndex(el, i);
end;

(**
 * Shorthand for calling [getEditValue] and [elementBySignature].
 *)
function evBySign(el: IInterface; sig: String): String;
begin
    result := gev(eBySign(el, sig));
end;

(**
 * Shorthand for calling [getEditValue] and [elementByPath].
 *)
function evByPath(el: IInterface; path: String): String;
begin
    result := gev(eByPath(el, path));
end;

(**
 * Shorthand for calling [getEditValue] and [elementByName].
 *)
function evByName(el: IInterface; nam: String): String;
begin
    result := gev(eByName(el, nam));
end;

(**
 * Shorthand for calling [getEditValue] and [elementByIndex].
 *)
function evByIndex(el: IInterface; i: Integer): String;
begin
    result := gev(eByIndex(el, i));
end;

(**
 * Shorthand for calling [linksTo] and [elementBySignature].
 *)
function linkBySign(el: IInterface; sig: String): IInterface;
begin
    result := linksTo(eBySign(el, sig));
end;

(**
 * Shorthand for calling [linksTo] and [elementByPath].
 *)
function linkByPath(el: IInterface; path: String): IInterface;
begin
    result := linksTo(eByPath(el, path));
end;

(**
 * Shorthand for calling [linksTo] and [elementByName].
 *)
function linkByName(el: IInterface; nam: String): IInterface;
begin
    result := linksTo(eByName(el, nam));
end;

(**
 * Shorthand for calling [linksTo] and [elementByIndex].
 *)
function linkByIndex(el: IInterface; i: Integer): IInterface;
begin
    result := linksTo(eByIndex(el, i));
end;


(**
 * Returns a lowercase string representation of [el]'s form ID.
 *
 * @param el  the record to return the form ID of
 * @return a lowercase string representation of [el]'s form ID
 *)
function stringFormID(el: IInterface): String;
begin
    result := lowerCase(intToHex(formID(el), 8));
end;



(***
 *
 * xEdit utility functions
 *
 **)

(**
 * Returns `true` iff [el] is referenced by a record with signature [sig].
 *
 * @param el   the element to check for references
 * @param sig  the signature to check
 * @return `true` iff [el] is referenced by a record with signature [sig]
 *)
function isReferencedBy(el: IInterface; sig: String): Boolean;
var i: Integer;
begin
    result := false;

    for i := 0 to referencedByCount(el) - 1 do begin
        if signature(referencedByIndex(el, i)) = sig then begin
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
