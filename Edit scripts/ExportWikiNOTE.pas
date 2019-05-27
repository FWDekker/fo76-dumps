unit ExportWikiNOTE;

uses ExportCore,
     ExportWikiCore;


var outputLines: TStringList;
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

    // AddMessage(evBySignature(e, 'FULL'));
    outputLines.Add('==' + evBySignature(e, 'FULL') + '==');
    outputLines.Add('Form ID: ' + StringFormID(e));
    outputLines.Add('Weight:  ' + evByPath(eBySignature(e, 'DATA'), 'Weight'));
    outputLines.Add('Value:   ' + evByPath(eBySignature(e, 'DATA'), 'Value'));
    outputLines.Add('Transcript: ' + #10 + GetNoteDialogue(e) + #10 + #10);
end;

function Finalize: integer;
begin
    CreateDir('dumps/');
    outputLines.SaveToFile('dumps/NOTE.wiki');
end;


function GetNoteDialogue(note: IInterface): string;
var scene: IInterface;
    actions: IInterface;
    actionList: TList;

    maxStage: integer;
    startStage: integer;
    endStage: integer;

    i: integer;
begin
    if (evByPath(eBySignature(note, 'SNAM'), 'Terminal') <> '') then
    begin
        Result := 'This disk shows terminal entries.';
        Exit;
    end;

    scene := LinksTo(eByPath(eBySignature(note, 'SNAM'), 'Scene'));
    actions := eByPath(scene, 'Actions');

    // Find max stage (and validate their values)
    maxStage := 0;
    for i := 0 to eCount(actions) - 1 do
    begin
        startStage := StrToInt(evBySignature(eByIndex(actions, i), 'SNAM'));
        endStage := StrToInt(evBySignature(eByIndex(actions, i), 'ENAM'));

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
    for i := 0 to eCount(actions) - 1 do
    begin
        startStage := StrToInt(evBySignature(eByIndex(actions, i), 'SNAM'));

        actionList.Delete(startStage);
        actionList.Insert(startStage, eByIndex(actions, i));
    end;

    // Iterate TList to build transcript
    Result := '{{Transcript|text=' + #10;

    for i := 0 to maxStage do
    begin
        if (evBySignature(ObjectToElement(actionList.Items[i]), 'DATA') <> '') then
        begin
            Result := Result + GetTopicDialogue(LinksTo(eBySignature(ObjectToElement(actionList.Items[i]), 'DATA'))) + #10 + #10;
        end;
    end;
    Delete(Result, Length(Result) - 1, 1); // Remove trailing newline

    Result := Result + '}}';
end;

function GetTopicDialogue(topic: IInterface): string;
var speaker: string;
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

    if (eCount(ChildGroup(topic)) <> 1) then
    begin
        AddMessage('ERROR - Unexpected no. of children');
        Result := 'ERROR';
        Exit;
    end;

    // Add speaker at start of paragraph
    speaker := evBySignature(LinksTo(eBySignature(eByIndex(ChildGroup(topic), 0), 'ANAM')), 'FULL');
    if (speaker = '') then
    begin
        speaker := evBySignature(LinksTo(eBySignature(eByIndex(ChildGroup(topic), 0), 'ANAM')), 'EDID');
    end;
    if ((speaker <> '_NPC_NoLines') AND (speaker <> lastSpeaker)) then
    begin
        Result := Result + '''''''' + speaker + ''''''': ';
    end;
    lastSpeaker := speaker;

    // Add lines of paragraph
    lines := eByPath(eByIndex(ChildGroup(topic), 0), 'Responses');
    for i := 0 to eCount(lines) do
    begin
        line := EscapeHTML(Trim(evBySignature(eByIndex(lines, i), 'NAM1')));
        comment := EscapeHTML(Trim(evBySignature(eByIndex(lines, i), 'NAM2')));
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


end.
