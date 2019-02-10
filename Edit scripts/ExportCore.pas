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



end.
