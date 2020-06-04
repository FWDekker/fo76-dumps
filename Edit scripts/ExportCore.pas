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

function getReferenceByIndexAndSig(e: IInterface; i: Integer; sig: String): IwbElement;
var ref: IwbElement;
begin
	ref := referencedByIndex(e, i);
	if signature(ref) = sig then begin
		result := ref;
		exit;
	end;
end;
	
function getLocationData(e: IInterface): TStringList;
var ExportTabularLOC_outputLines: TStringList;
var ref: IwbElement;
var i: Integer;

var data: IInterface;
var cell: IInterface;
var worldspace: IInterface;
begin
	ExportTabularLOC_outputLines := TStringList.create();
	
	for i := 0 to referencedByCount(e) - 1 do begin
		
		ref := getReferenceByIndexAndSig(e,i,'REFR');
		
		if isRefLocation(ref) then begin
			// we only want the ones in the Appalachia worldspace
			data := ElementBySignature(ref, 'DATA');
			
			ExportTabularLOC_outputLines.add(
				  escapeCsvString(getFileName(getFile(ref))) + ', '
				+ escapeCsvString(stringFormID(ref)) + ', '
				+ escapeCsvString(evBySign(e, 'EDID')) + ', '
				+ escapeCsvString(evBySign(e, 'FULL')) + ', '
				+ escapeCsvString(evBySign(ref, 'XLYR')) + ', '
				+ escapeCsvString(gev(ElementByName(ref, 'Cell'))) + ', '
				+ escapeCsvString(vec3ToString(ElementByName(data,'Position'))) + ', '
				+ escapeCsvString(vec3ToString(ElementByName(data,'Rotation')))
			);
		end;
	end;
	
	result := ExportTabularLOC_outputLines;
end;	

function initializeLocationTabular(): TStringList;
var ExportTabularLOC_outputLines: TStringList;
begin
	ExportTabularLOC_outputLines := TStringList.create();
	ExportTabularLOC_outputLines.add(
            '"File"'                 // Name of the originating ESM
        + ', "Form ID"'              // Form ID
        + ', "Editor ID"'            // Editor ID of item
        + ', "Name"'                 // Full name of item
        + ', "Layer"'                // Layer the reference is linked to
		+ ', "Cell"'                 // World Cell
		+ ', "Position"'             // Vector3 Position
		+ ', "Rotation"'             // Vector3 Rotation        
    );
	result := ExportTabularLOC_outputLines;
end;

function vec3ToString(e: IInterface): String;
begin
	result := gev(ElementByName(e,'X')) + ':' + gev(ElementByName(e,'Y')) + ':' + gev(ElementByName(e,'Z'));
end;

function debugPrint(e: IInterface):  Boolean;
var i: Integer;
var ei: IwbElement;
begin
	for i := 0 to ElementCount(e) - 1 do begin
		ei := ElementByIndex(e,i);
		addMessage('Found: ' + name(ei) + ' sig: ' + Signature(ei) + ' name: ' + gev(ei));
		
	end;
	result := True;
end;

function isRefLocation(e: IInterface): Boolean;
var data: IInterface;
begin
	result := false;

	data := eBySign(e, 'DATA');
	if (signature(e) = 'REFR') AND ElementExists(data,'Position') then begin
		result := True;
		exit;
	end;
	
end;

    

end.
