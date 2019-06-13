unit ExportWikiDIAL;

uses ExportCore,
     ExportWikiCore;


var outputLines: TStringList;


function initialize: Integer;
begin
    outputLines := TStringList.create;
end;

function process(e: IInterface): Integer;
begin
    // Filter out nested elements
    if signature(e) <> 'QUST' then begin
        exit;
    end;

    addQuest(outputLines, e);
end;

function finalize: Integer;
begin
    createDir('dumps/');
    outputLines.saveToFile('dumps/DIAL.wiki');
end;


procedure addQuest(output: TStringList; quest: IInterface);
var linkable: Integer;

    topics: IInterface;
    topic: IInterface;
    topicSize: Integer;
    topicHasRowSpan: Boolean;
    previousTopic: Integer;

    dialogs: IInterface;
    dialog: IInterface;
    dialogHasRowSpan: Boolean;
    previousDialog: Integer;

    responses: IInterface;
    response: IInterface;

    i: Integer;
begin
    if signature(quest) <> 'QUST' then begin
        exit;
    end;

    topics := childGroup(quest);
    if eCount(topics) = 0 then begin
        exit;
    end;

    outputLines.add('==[' + getFileName(getFile(e)) + '] ' + evBySignature(quest, 'EDID') + ' (' + stringFormID(quest) + ')==');
    outputLines.add('{|class="va-table va-table-full np-table-dialogue"');
    outputLines.add('|-');
    outputLines.add('! style="width:2%" | #');
    outputLines.add('! style="width:8%" | Dialog Topic');
    outputLines.add('! style="width:5%" | Form ID');
    outputLines.add('! style="width:30%" | Response Text');
    outputLines.add('! style="width:30%" | Script Notes');
    outputLines.add('');

    linkable := 1;

    previousTopic := 0;
    while true do begin
        topic := getElementAfter(topics, previousTopic);
        if not assigned(topic) then begin
            break;
        end;
        previousTopic := formID(topic);

        if signature(topic) <> 'DIAL' then begin
            continue;
        end;

        dialogs := childGroup(topic);
        topicHasRowSpan := false;
        topicSize := 0;

        for i := 0 to eCount(dialogs) - 1 do begin
            dialog := eByIndex(dialogs, i);
            responses := eByPath(dialog, 'Responses');

            topicSize := topicSize + eCount(responses);
        end;

        previousDialog := 0;
        while true do begin
            dialog := getElementAfter(dialogs, previousDialog);
            if (not assigned(dialog)) then begin
                break;
            end;
            previousDialog := formID(dialog);
            dialogHasRowSpan := false;

            responses := eByPath(dialog, 'Responses');
            for i := 0 to eCount(responses) - 1 do begin
                response := eByIndex(responses, i);

                outputLines.add('|-');
                outputLines.add('| {{Linkable|' + intToStr(linkable) + '}}');
                if not topicHasRowSpan then begin
                    outputLines.add('| rowspan="' + intToStr(topicSize) + '" | {{ID|' + stringFormID(topic) + '}}');
                    topicHasRowSpan := true;
                end;
                if not dialogHasRowSpan then begin
                    if eCount(responses) = 1 then begin
                        outputLines.add('| {{ID|' + stringFormID(dialog) + '}}');
                    end else begin
                        outputLines.add('| rowspan="'
                            + intToStr(eCount(responses)) + '" | {{ID|' + stringFormID(dialog) + '}}');
                    end;
                    dialogHasRowSpan := true;
                end;
                outputLines.add('| ' + escapeHTML(trim(evBySignature(response, 'NAM1'))));
                outputLines.add('| ''''' + escapeHTML(trim(evBySignature(response, 'NAM2'))) + '''''');
                outputLines.add('');

                linkable := linkable + 1;
            end;
        end;
    end;


    outputLines.add('|}');
    outputLines.add(#10);
end;

function getElementAfter(group: IInterface; previousFormID: Integer): IInterface;
var i: Integer;
    e: IInterface;
    nextFormID: Integer;
begin
    nextFormID := -1;

    for i := 0 to eCount(group) - 1 do begin
        e := eByIndex(group, i);

        if (formID(e) > previousFormID) and ((formID(e) <= nextFormID) or (nextFormId = -1)) then begin
            nextFormID := formID(e);
        end;
    end;

    for i := 0 to eCount(group) - 1 do begin
        e := eByIndex(group, i);

        if formID(e) = nextFormID then begin
            result := e;
            exit;
        end;
    end;

    result := nil;
end;


end.
