unit _ExportWikiNOTE;

var
    outputLines: TStringList;
    lastSpeaker: string;


function Initialize: integer;
begin
    outputLines := TStringList.Create;
end;

function Process(e: IInterface): integer;
begin
    if (Signature(e) <> 'NOTE') then
    begin
        AddMessage('Warning: ' + Name(e) + ' is not a NOTE');
        Exit;
    end;

    lastSpeaker := '';

    // AddMessage(GetEditValue(ElementBySignature(e, 'FULL')));
    outputLines.Add('==' + GetEditValue(ElementBySignature(e, 'FULL')) + '==');
    outputLines.Add('Form ID: ' + LowerCase(IntToHex(FormID(e), 8)));
    outputLines.Add('Weight:  ' + GetEditValue(ElementByPath(ElementBySignature(e, 'DATA'), 'Weight')));
    outputLines.Add('Value:   ' + GetEditValue(ElementByPath(ElementBySignature(e, 'DATA'), 'Value')));
    outputLines.Add('Transcript: ' + #10 + GetNoteDialogue(e) + #10 + #10);
end;

function Finalize: integer;
begin
    if (outputLines.Count > 0) then
    begin
        outputLines.SaveToFile('fo76_dump_note.wiki');
    end;
end;


function GetNoteDialogue(note: IInterface): string;
var
    scene: IInterface;
    actions: IInterface;
    actionList: TList;

    maxStage: integer;
    startStage: integer;
    endStage: integer;

    i: integer;
begin
    if (GetEditValue(ElementByPath(ElementBySignature(note, 'SNAM'), 'Terminal')) <> '') then
    begin
        Result := 'This disk shows terminal entries.';
        Exit;
    end;

    scene := LinksTo(ElementByPath(ElementBySignature(note, 'SNAM'), 'Scene'));
    actions := ElementByPath(scene, 'Actions');

    // Find max stage (and validate their values)
    maxStage := 0;
    for i := 0 to ElementCount(actions) - 1 do
    begin
        startStage := StrToInt(GetEditValue(ElementBySignature(ElementByIndex(actions, i), 'SNAM')));
        endStage := StrToInt(GetEditValue(ElementBySignature(ElementByIndex(actions, i), 'ENAM')));

        if (startStage < 0) then
        begin
            AddMessage('ERROR - Negative ENAM');
            Result := 'ERROR';
            Exit;
        end;

        if (startStage > endStage) then
        begin
            AddMessage('ERROR - ENAM greater than SNAM');
            Result := 'ERROR';
            Exit;
        end;

        if (endStage > maxStage) then
        begin
            maxStage := endStage;
        end;
    end;

    // Allocate TList
    actionList := TList.Create;
    for i := 0 to maxStage do
    begin
        actionList.Add(NULL);
    end;

    // Populate TList
    for i := 0 to ElementCount(actions) - 1 do
    begin
        startStage := StrToInt(GetEditValue(ElementBySignature(ElementByIndex(actions, i), 'SNAM')));

        actionList.Delete(startStage);
        actionList.Insert(startStage, ElementByIndex(actions, i));
    end;

    // Iterate TList to build transcript
    Result := '{{Transcript|text=' + #10;

    for i := 0 to maxStage do
    begin
        if (GetEditValue(ElementBySignature(ObjectToElement(actionList.Items[i]), 'DATA')) <> '') then
        begin
            Result := Result + GetTopicDialogue(LinksTo(ElementBySignature(ObjectToElement(actionList.Items[i]), 'DATA'))) + #10 + #10;
        end;
    end;
    Delete(Result, Length(Result) - 1, 1); // Remove trailing newline

    Result := Result + '}}';
end;

function GetTopicDialogue(topic: IInterface): string;
var
    speaker: string;
    lines: IInterface;
    line: string;
    comment: string;

    i: integer;
begin
    if (Signature(topic) <> 'DIAL') then
    begin
        AddMessage('ERROR - Unexpected signature: ' + Signature(topic));
        Result := 'ERROR';
        Exit;
    end;

    if (ElementCount(ChildGroup(topic)) <> 1) then
    begin
        AddMessage('ERROR - Unexpected no. of children');
        Result := 'ERROR';
        Exit;
    end;

    // Add speaker at start of paragraph
    speaker := GetEditValue(ElementBySignature(LinksTo(ElementBySignature(ElementByIndex(ChildGroup(topic), 0), 'ANAM')), 'FULL'));
    if (speaker = '') then
    begin
        speaker := GetEditValue(ElementBySignature(LinksTo(ElementBySignature(ElementByIndex(ChildGroup(topic), 0), 'ANAM')), 'EDID'));
    end;
    if ((speaker <> '_NPC_NoLines') AND (speaker <> lastSpeaker)) then
    begin
        Result := Result + '''''''' + speaker + ''''''': ';
    end;
    lastSpeaker := speaker;

    // Add lines of paragraph
    lines := ElementByPath(ElementByIndex(ChildGroup(topic), 0), 'Responses');
    for i := 0 to ElementCount(lines) do
    begin
        line := EscapeHTML(Trim(GetEditValue(ElementBySignature(ElementByIndex(lines, i), 'NAM1'))));
        comment := EscapeHTML(Trim(GetEditValue(ElementBySignature(ElementByIndex(lines, i), 'NAM2'))));
        comment := StringReplace(comment, '"', '&quot;', [rfReplaceAll]);

        if (Trim(comment) = '') then
        begin
            if ((Result = '') AND (Pos('*', line) = 1)) then
            begin
                Result := Result + '<nowiki>' + line + '</nowiki> ';
            end
            else
            begin
                Result := Result + line + ' ';
            end;
        end
        else
            Result := Result + '{{tooltip|' + line + '|' + comment + '}}' + ' ';
        begin
        end;
    end;

    Result := Trim(Result);
end;

function EscapeHTML(text: string): string;
begin
    Result := text;
    Result := StringReplace(Result, '<', '&lt;', [rfReplaceAll]);
    Result := StringReplace(Result, '>', '&gt;', [rfReplaceAll]);
end;


end.
