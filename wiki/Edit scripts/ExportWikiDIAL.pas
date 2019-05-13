unit ExportWikiDIAL;

uses ExportCore,
     ExportWikiCore;


var outputLines: TStringList;


function Initialize: integer;
begin
    outputLines := TStringList.Create;
end;

function Process(e: IInterface): integer;
begin
    AddQuest(outputLines, e);
end;

function Finalize: integer;
begin
    CreateDir('dumps/');
    outputLines.SaveToFile('dumps/DIAL.wiki');
end;


procedure AddQuest(output: TStringList; quest: IInterface);
var linkable: integer;

    topics: IInterface;
    topic: IInterface;
    topicSize: integer;
    topicHasRowSpan: boolean;
    previousTopic: integer;

    dialogs: IInterface;
    dialog: IInterface;
    dialogHasRowSpan: boolean;
    previousDialog: integer;

    responses: IInterface;
    response: IInterface;

    i: integer;
begin
    if (Signature(quest) <> 'QUST') then
    begin
        Exit;
    end;

    topics := ChildGroup(quest);
    if (eCount(topics) = 0) then
    begin
        Exit;
    end;

    outputLines.Add('==' + evBySignature(quest, 'EDID') + '==');
    outputLines.Add('{|class="va-table va-table-full np-table-dialogue"');
    outputLines.Add('|-');
    outputLines.Add('! style="width:2%" | #');
    outputLines.Add('! style="width:8%" | Dialog Topic');
    outputLines.Add('! style="width:5%" | Form ID');
    outputLines.Add('! style="width:30%" | Response Text');
    outputLines.Add('! style="width:30%" | Script Notes');
    outputLines.Add('');

    linkable := 1;

    previousTopic := 0;
    while true do
    begin
        topic := GetElementAfter(topics, previousTopic);
        if (not Assigned(topic)) then
        begin
            Break;
        end;
        previousTopic := FormID(topic);

        if (Signature(topic) <> 'DIAL')  then
        begin
            Continue;
        end;

        dialogs := ChildGroup(topic);
        topicHasRowSpan := false;
        topicSize := 0;

        for i := 0 to eCount(dialogs) - 1 do
        begin
            dialog := eByIndex(dialogs, i);
            responses := eByPath(dialog, 'Responses');

            topicSize := topicSize + eCount(responses);
        end;

        previousDialog := 0;
        while true do
        begin
            dialog := GetElementAfter(dialogs, previousDialog);
            if (not Assigned(dialog)) then
            begin
                Break;
            end;
            previousDialog := FormID(dialog);
            dialogHasRowSpan := false;

            responses := eByPath(dialog, 'Responses');
            for i := 0 to eCount(responses) - 1 do
            begin
                response := eByIndex(responses, i);

                outputLines.Add('|-');
                outputLines.Add('| {{Linkable|' + IntToStr(linkable) + '}}');
                if (not topicHasRowSpan) then
                begin
                    outputLines.Add('| rowspan="' + IntToStr(topicSize) + '" | {{ID|' + StringFormID(topic) + '}}');
                    topicHasRowSpan := true;
                end;
                if (not dialogHasRowSpan) then
                begin
                    if (eCount(responses) = 1) then
                    begin
                        outputLines.Add('| {{ID|' + StringFormID(dialog) + '}}');
                    end
                    else
                    begin
                        outputLines.Add('| rowspan="' + IntToStr(eCount(responses)) + '" | {{ID|' + StringFormID(dialog) + '}}');
                    end;
                    dialogHasRowSpan := true;
                end;
                outputLines.Add('| ''''' + EscapeHTML(Trim(evBySignature(response, 'NAM1'))) + '''''');
                outputLines.Add('| ''''' + EscapeHTML(Trim(evBySignature(response, 'NAM2'))) + '''''');
                outputLines.Add('');

                linkable := linkable + 1;
            end;
        end;
    end;


    outputLines.Add('|}');
    outputLines.Add(#10);
end;

function GetElementAfter(group: IInterface; previousFormID: integer): IInterface;
var i: integer;
    e: IInterface;
    nextFormID: integer;
begin
    nextFormID := -1;

    for i := 0 to eCount(group) - 1 do
    begin
        e := eByIndex(group, i);

        if ((FormID(e) > previousFormID) and ((FormID(e) <= nextFormID) or (nextFormId = -1))) then
        begin
            nextFormID := FormID(e);
        end;
    end;

    for i := 0 to eCount(group) - 1 do
    begin
        e := eByIndex(group, i);

        if (FormID(e) = nextFormID) then
        begin
            Result := e;
            Exit;
        end;
    end;

    Result := nil;
end;


end.
