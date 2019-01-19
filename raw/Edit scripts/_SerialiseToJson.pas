unit _SerialiseToJson;

var
    outputLines: TStringList;


function Initialize: integer;
begin
    outputLines := TStringList.Create;
    outputLines.Add('{');
end;

function Process(e: IInterface): integer;
begin
    if (outputLines.Count > 1) then
    begin
        outputLines.Add('    ,');
    end;

    outputLines.Add('    "' + IntToHex(FormID(e), 8) + '" : ' + Serialize(e, 1));
end;

function Finalize: integer;
begin
    outputLines.Add('}');

    if (outputLines.Count > 0) then
    begin
        outputLines.SaveToFile('fo76_dump_all.json');
    end;
end;


function Serialize(e: IInterface; indentLevel: integer): string;
var
    eType: Integer;
begin
    eType := ElementType(e);

    if ((Ord(eType) = Ord(etValue)) OR (Ord(eType) = Ord(etFlag))) then
    begin
        Result := SerializeValue(e);
    end
    else if (Ord(eType) = Ord(etSubRecord)) then
    begin
        if (ElementCount(e) = 0) then
        begin
            Result := SerializeValue(e);
        end
        else
        begin
            Result := SerializeObject(e, indentLevel);
        end;
    end
    else if ((Ord(eType) = Ord(etMainRecord)) OR (Ord(eType) = Ord(etStruct)) OR (Ord(eType) = Ord(etSubRecordStruct)) OR (Ord(eType) = Ord(etUnion))) then
    begin
        Result := SerializeObject(e, indentLevel);
    end
    else if ((Ord(eType) = Ord(etArray)) OR (Ord(eType) = Ord(etSubRecordArray))) then
    begin
        Result := SerializeArray(e, indentLevel);
    end
    else
    begin
        // Error
        AddMessage('UNKNOWN TYPE!!! ' + Name(e) + ' // ' + etToString(ElementType(e)));
        Result := '"<! DUMP ERROR. UNKNOWN TYPE `' + etToString(ElementType(e)) + '` !>"';
    end;
end;

function SerializeValue(e: IInterface): string;
begin
    Result := '"' + EscapeJsonString(GetEditValue(e)) + '"';
end;

function SerializeObject(e: IInterface; indentLevel: integer): string;
var
    i: integer;
    element: IInterface;
begin
    if (ElementCount(e) = 0) then
    begin
        Result := '{}';
        Exit;
    end;


    Result := '{' + #10;

    for i := 0 to ElementCount(e) - 1 do
    begin
        element := ElementByIndex(e, i);
        Result := Result + Indent(indentLevel + 1) + '"' + Name(element) + '" : ' + Serialize(element, indentLevel + 1);

        if (i < (ElementCount(e) - 1)) then
        begin
            Result := Result + ',';
        end;

        Result := Result + #10;
    end;

    Result := Result + Indent(indentLevel) + '}';
end;

function SerializeArray(e: IInterface; indentLevel: integer): string;
var
    i: integer;
    element: IInterface;
begin
    if (ElementCount(e) = 0) then
    begin
        Result := '[]';
        Exit;
    end;


    Result := '[' + #10;

    for i := 0 to ElementCount(e) - 1 do
    begin
        Result := Result + Indent(indentLevel + 1) + Serialize(ElementByIndex(e, i), indentLevel + 1);

        if (i < (ElementCount(e) - 1)) then
        begin
            Result := Result + ',';
        end;

        Result := Result + #10;
    end;

    Result := Result + Indent(indentLevel) + ']';
end;


function Indent(indentLevel: integer): string;
var
    i: integer;
begin
    Result := '';

    for i := 0 to (indentLevel - 1) do
    begin
        Result := Result + '    ';
    end;
end;

function EscapeJsonString(s: string): string;
begin
    Result := s;

    // Escape "normal" characters
    Result := StringReplace(Result, '\', '\\', [rfReplaceAll]);
    Result := StringReplace(Result, '"', '\"', [rfReplaceAll]);

    // No multiline strings
    Result := StringReplace(Result, #13 + #10, '\n', [rfReplaceAll]);
    Result := StringReplace(Result, #10, '\n', [rfReplaceAll]);

    // Escape control characters
    Result := StringReplace(Result, #1, '\u0001', [rfReplaceAll]);
    Result := StringReplace(Result, #2, '\u0002', [rfReplaceAll]);
    Result := StringReplace(Result, #3, '\u0003', [rfReplaceAll]);
    Result := StringReplace(Result, #4, '\u0004', [rfReplaceAll]);
    Result := StringReplace(Result, #5, '\u0005', [rfReplaceAll]);
    Result := StringReplace(Result, #6, '\u0006', [rfReplaceAll]);
    Result := StringReplace(Result, #7, '\u0007', [rfReplaceAll]);
    Result := StringReplace(Result, #8, '\u0008', [rfReplaceAll]);
    Result := StringReplace(Result, #9, '\u0009', [rfReplaceAll]);
    // Result := StringReplace(Result, #10, '\u000a', [rfReplaceAll]); // See above
    Result := StringReplace(Result, #11, '\u000b' + #11, [rfReplaceAll]);
    Result := StringReplace(Result, #12, '\u000c' + #12, [rfReplaceAll]);
    Result := StringReplace(Result, #13, '\u000d' + #13, [rfReplaceAll]);
    Result := StringReplace(Result, #14, '\u000e' + #14, [rfReplaceAll]);
    Result := StringReplace(Result, #15, '\u000f' + #15, [rfReplaceAll]);
    Result := StringReplace(Result, #16, '\u0010' + #16, [rfReplaceAll]);
    Result := StringReplace(Result, #17, '\u0011' + #17, [rfReplaceAll]);
    Result := StringReplace(Result, #18, '\u0012' + #18, [rfReplaceAll]);
    Result := StringReplace(Result, #19, '\u0013' + #19, [rfReplaceAll]);
    Result := StringReplace(Result, #20, '\u0014' + #20, [rfReplaceAll]);
    Result := StringReplace(Result, #21, '\u0015' + #21, [rfReplaceAll]);
    Result := StringReplace(Result, #22, '\u0016' + #22, [rfReplaceAll]);
    Result := StringReplace(Result, #23, '\u0017' + #23, [rfReplaceAll]);
    Result := StringReplace(Result, #24, '\u0018' + #24, [rfReplaceAll]);
    Result := StringReplace(Result, #25, '\u0019' + #25, [rfReplaceAll]);
    Result := StringReplace(Result, #26, '\u001a' + #26, [rfReplaceAll]);
    Result := StringReplace(Result, #27, '\u001b' + #27, [rfReplaceAll]);
    Result := StringReplace(Result, #28, '\u001c' + #28, [rfReplaceAll]);
    Result := StringReplace(Result, #29, '\u001d' + #29, [rfReplaceAll]);
    Result := StringReplace(Result, #30, '\u001e' + #30, [rfReplaceAll]);
    Result := StringReplace(Result, #31, '\u001f' + #31, [rfReplaceAll]);
end;


function etToString(et: TwbElementType): string;
begin
  case Ord(et) of
    Ord(etFile): Result := 'etFile';
    Ord(etMainRecord): Result := 'etMainRecord';
    Ord(etGroupRecord): Result := 'etGroupRecord';
    Ord(etSubRecord): Result := 'etSubRecord';
    Ord(etSubRecordStruct): Result := 'etSubRecordStruct';
    Ord(etSubRecordArray): Result := 'etSubRecordArray';
    Ord(etSubRecordUnion): Result := 'etSubRecordUnion';
    Ord(etArray): Result := 'etArray';
    Ord(etStruct): Result := 'etStruct';
    Ord(etValue): Result := 'etValue';
    Ord(etFlag): Result := 'etFlag';
    Ord(etStringListTerminator): Result := 'etStringListTerminator';
    Ord(etUnion): Result := 'etUnion';
  end;
end;


end.
