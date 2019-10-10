unit ExportWikiDIAL;

uses ExportCore,
     ExportWikiCore;


var ExportWikiDIAL_outputLines: TStringList;


function initialize: Integer;
begin
    ExportWikiDIAL_outputLines := TStringList.create;
end;

function canProcess(e: IInterface): Boolean;
begin
    result := signature(e) = 'QUST';
end;

function process(dial: IInterface): Integer;
var transcript: String;
begin
    // Filter out non-quest elements and nested elements
    if not canProcess(dial) then begin
        // No warning needed because this is expected behavior
        exit;
    end;

    transcript := trim(getQuestTranscript(dial));
    if not (transcript = '') then begin
        ExportWikiDIAL_outputLines.add(transcript + #10 + #10);
    end;
end;

function finalize: Integer;
begin
    createDir('dumps/');
    ExportWikiDIAL_outputLines.saveToFile('dumps/DIAL.wiki');
end;


function getQuestTranscript(quest: IInterface): String;
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

    result := result
        + '==[' + getFileName(getFile(quest)) + '] ' + evBySignature(quest, 'EDID')
            + ' (' + stringFormID(quest) + ')==' + #10
        + '{|class="va-table va-table-full np-table-dialogue"' + #10
        + '|-' + #10
        + '! style="width:2%" | #' + #10
        + '! style="width:8%" | Dialog Topic' + #10
        + '! style="width:5%" | Form ID' + #10
        + '! style="width:30%" | Response Text' + #10
        + '! style="width:30%" | Script Notes' + #10
        + #10;

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
            if not assigned(dialog) then begin
                break;
            end;
            previousDialog := formID(dialog);
            dialogHasRowSpan := false;

            responses := eByPath(dialog, 'Responses');
            for i := 0 to eCount(responses) - 1 do begin
                response := eByIndex(responses, i);

                result := result
                    + '|-' + #10
                    + '| {{Linkable|' + intToStr(linkable) + '}}' + #10;
                if not topicHasRowSpan then begin
                    result := result
                        + '| rowspan="' + intToStr(topicSize) + '" | {{ID|' + stringFormID(topic) + '}}' + #10;
                    topicHasRowSpan := true;
                end;
                if not dialogHasRowSpan then begin
                    if eCount(responses) = 1 then begin
                        result := result + '| {{ID|' + stringFormID(dialog) + '}}' + #10;
                    end else begin
                        result := result
                            + '| rowspan="' + intToStr(eCount(responses))
                                + '" | {{ID|' + stringFormID(dialog) + '}}' + #10;
                    end;
                    dialogHasRowSpan := true;
                end;
                result := result
                    + '| ' + escapeHTML(trim(evBySignature(response, 'NAM1'))) + #10
                    + '| ''''' + escapeHTML(trim(evBySignature(response, 'NAM2'))) + '''''' + #10
                    + '' + #10;

                linkable := linkable + 1;
            end;
        end;
    end;


    result := result + '|}';
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
