(**
 * A collection of functions shared between the different export types. 
 *)
unit ExportCore;


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
 * Returns `true` iff [e] is referenced by a record with signature [sig].
 *
 * @param e   the element to check for references
 * @param sig the signature to check
 * @return `true` iff [e] is referenced by a record with signature [sig]
 *)
function IsReferencedBy(e: IInterface; sig: string): boolean;
var
    i: integer;
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


end.
