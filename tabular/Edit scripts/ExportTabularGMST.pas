unit ExportTabularGMST;

uses ExportTabularCore;


var outputLines: TStringList;


function Initialize: integer;
begin
    outputLines := TStringList.Create;
    outputLines.Add('"Form ID", "Editor ID", "Type", "Value"');
end;

function Process(e: IInterface): integer;
begin
    outputLines.Add(
        EscapeCsvString(LowerCase(IntToHex(FormID(e), 8))) + ', ' +
        EscapeCsvString(GetEditValue(ElementBySignature(e, 'EDID'))) + ', ' +
        EscapeCsvString(LetterToType(copy(GetEditValue(ElementBySignature(e, 'EDID')), 1, 1))) + ', ' +
        EscapeCsvString(GetEditValue(LastElement(ElementBySignature(e, 'DATA'))))
    );
end;

function Finalize: integer;
begin
    if (outputLines.Count > 0) then
    begin
        CreateDir('dumps/');
        outputLines.SaveToFile('dumps/GMST.csv');
    end;
end;


function LetterToType(letter: string): string;
begin
    if (letter = 'b') then
    begin
        Result := 'boolean';
    end
    else if (letter = 'f') then
    begin
        Result := 'float';
    end
    else if (letter = 'i') then
    begin
        Result := 'integer';
    end
    else if (letter = 's') then
    begin
        Result := 'string';
    end
    else if (letter = 'u') then
    begin
        Result := 'unsigned integer';
    end
    else
    begin
        AddMessage('<! DUMP ERROR. UNKNOWN TYPE `' + letter + '` !>');
        Result := '<! DUMP ERROR. UNKNOWN TYPE `' + letter + '` !>';
    end;
end;


end.
