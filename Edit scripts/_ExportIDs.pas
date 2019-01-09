unit _ExportIDs;

var
    outputLines: TStringList;


function Initialize: integer;
begin
    outputLines := TStringList.Create;
    outputLines.Add('"Signature", "Form ID", "Editor ID", "Name"');
end;

function Process(e: IInterface): integer;
begin
    outputLines.Add(
        '"' + Signature(e) + '", ' +
        '"' + LowerCase(IntToHex(FormID(e), 8)) + '", ' +
        '"' + GetEditValue(ElementBySignature(e, 'EDID')) + '", ' +
        '"' + GetEditValue(ElementBySignature(e, 'FULL')) + '"');
end;

function Finalize: integer;
begin
    if (outputLines.Count > 0) then
    begin
        outputLines.SaveToFile('fo76_dump_ids.csv');
    end;
end;


end.
