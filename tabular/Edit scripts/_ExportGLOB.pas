unit _ExportGLOB;

var
    outputLines: TStringList;


function Initialize: integer;
begin
    outputLines := TStringList.Create;
    outputLines.Add('"Form ID", "Editor ID", "Value"');
end;

function Process(e: IInterface): integer;
begin
    outputLines.Add(
        '"' + LowerCase(IntToHex(FormID(e), 8)) + '", ' +
        '"' + GetEditValue(ElementBySignature(e, 'EDID')) + '", ' +
        GetEditValue(ElementBySignature(e, 'FLTV')));
end;

function Finalize: integer;
begin
    if (outputLines.Count > 0) then
    begin
        outputLines.SaveToFile('fo76_dump_globs.csv');
    end;
end;


end.
