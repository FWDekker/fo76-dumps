unit ExportWikiNOTE;

uses ExportCore,
     ExportWikiCore;


var outputLines: TStringList;
    lastSpeaker: String;


function initialize: Integer;
begin
    outputLines := TStringList.create;
end;

function process(e: IInterface): Integer;
begin
    if (signature(e) <> 'NOTE') then begin
        addMessage('Warning: ' + name(e) + ' is not a NOTE');
        exit;
    end;

    lastSpeaker := '';

    // AddMessage(evBySignature(e, 'FULL'));
    outputLines.add('==' + evBySignature(e, 'FULL') + '==');
    outputLines.add('Form ID: ' + stringFormID(e));
    outputLines.add('Weight:  ' + evByPath(eBySignature(e, 'DATA'), 'Weight'));
    outputLines.add('Value:   ' + evByPath(eBySignature(e, 'DATA'), 'Value'));
    outputLines.add('Transcript: ' + #10 + getNoteDialogue(e) + #10 + #10);
end;

function finalize: Integer;
begin
    createDir('dumps/');
    outputLines.saveToFile('dumps/NOTE.wiki');
end;


function getNoteDialogue(note: IInterface): String;
var scene: IInterface;
    actions: IInterface;
    actionList: TList;

    maxStage: Integer;
    startStage: Integer;
    endStage: Integer;

    i: Integer;
begin
    if (evByPath(eBySignature(note, 'SNAM'), 'Terminal') <> '') then begin
        result := 'This disk shows terminal entries.';
        exit;
    end;

    scene := linksTo(eByPath(eBySignature(note, 'SNAM'), 'Scene'));
    actions := eByPath(scene, 'Actions');

    // Find max stage (and validate their values)
    maxStage := 0;
    for i := 0 to eCount(actions) - 1 do begin
        startStage := strToInt(evBySignature(eByIndex(actions, i), 'SNAM'));
        endStage := strToInt(evBySignature(eByIndex(actions, i), 'ENAM'));

        if (startStage < 0) then begin
            addMessage('ERROR - Negative ENAM');
            result := 'ERROR';
            exit;
        end;

        if (startStage > endStage) then begin
            addMessage('ERROR - ENAM greater than SNAM');
            result := 'ERROR';
            exit;
        end;

        if (endStage > maxStage) then begin
            maxStage := endStage;
        end;
    end;

    // Allocate TList
    actionList := TList.create;
    for i := 0 to maxStage do begin
        actionList.add(NULL);
    end;

    // Populate TList
    for i := 0 to eCount(actions) - 1 do begin
        startStage := strToInt(evBySignature(eByIndex(actions, i), 'SNAM'));

        actionList.delete(startStage);
        actionList.insert(startStage, eByIndex(actions, i));
    end;

    // Iterate TList to build transcript
    result := '{{Transcript|text=' + #10;

    for i := 0 to maxStage do begin
        if (evBySignature(objectToElement(actionList.items[i]), 'DATA') <> '') then begin
            result := result + getTopicDialogue(linksTo(eBySignature(objectToElement(actionList.items[i]), 'DATA'))) + #10 + #10;
        end;
    end;
    delete(result, length(result) - 1, 1); // Remove trailing newline

    result := result + '}}';
end;

function getTopicDialogue(topic: IInterface): String;
var speaker: String;
    lines: IInterface;
    line: String;
    comment: String;

    i: Integer;
begin
    if (signature(topic) <> 'DIAL') then begin
        addMessage('ERROR - Unexpected signature: ' + signature(topic));
        result := 'ERROR';
        exit;
    end;

    if (eCount(childGroup(topic)) <> 1) then begin
        addMessage('ERROR - Unexpected no. of children');
        result := 'ERROR';
        exit;
    end;

    // Add speaker at start of paragraph
    speaker := evBySignature(linksTo(eBySignature(eByIndex(childGroup(topic), 0), 'ANAM')), 'FULL');
    if (speaker = '') then begin
        speaker := evBySignature(linksTo(eBySignature(eByIndex(childGroup(topic), 0), 'ANAM')), 'EDID');
    end;
    if ((speaker <> '_NPC_NoLines') and (speaker <> lastSpeaker)) then begin
        result := result + '''''''' + speaker + ''''''': ';
    end;
    lastSpeaker := speaker;

    // Add lines of paragraph
    lines := eByPath(eByIndex(childGroup(topic), 0), 'Responses');
    for i := 0 to eCount(lines) do begin
        line := escapeHTML(trim(evBySignature(eByIndex(lines, i), 'NAM1')));
        comment := escapeHTML(trim(evBySignature(eByIndex(lines, i), 'NAM2')));
        comment := stringReplace(comment, '"', '&quot;', [rfReplaceAll]);

        if (trim(comment) = '') then begin
            if ((result = '') and (pos('*', line) = 1)) then begin
                result := result + '<nowiki>' + line + '</nowiki> ';
            end else begin
                result := result + line + ' ';
            end;
        end else begin
            result := result + '{{tooltip|' + line + '|' + comment + '}}' + ' '; 
        end;
    end;

    result := trim(result);
end;


end.
