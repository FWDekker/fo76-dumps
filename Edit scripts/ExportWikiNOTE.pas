unit ExportWikiNOTE;

uses ExportCore,
     ExportWikiCore;


var ExportWikiNOTE_outputLines: TStringList;
    ExportWikiNOTE_lastSpeaker: String;


function initialize: Integer;
begin
    ExportWikiNOTE_outputLines := TStringList.create();
end;

function canProcess(e: IInterface): Boolean;
begin
    result := signature(e) = 'NOTE';
end;

function process(note: IInterface): Integer;
begin
    if not canProcess(note) then begin
        addMessage('Warning: ' + name(note) + ' is not a NOTE. Entry was ignored.');
        exit;
    end;

    ExportWikiNOTE_lastSpeaker := '';

    ExportWikiNOTE_outputLines.add('==[' + getFileName(getFile(note)) + '] ' + evBySign(note, 'FULL') + '==');
    ExportWikiNOTE_outputLines.add('Form ID:   ' + stringFormID(note));
    ExportWikiNOTE_outputLines.add('Editor ID: ' + evBySign(note, 'EDID'));
    ExportWikiNOTE_outputLines.add('Weight:    ' + evByPath(eBySign(note, 'DATA'), 'Weight'));
    ExportWikiNOTE_outputLines.add('Value:     ' + evByPath(eBySign(note, 'DATA'), 'Value'));
    ExportWikiNOTE_outputLines.add('Transcript: ' + #10 + getNoteDialogue(note) + #10 + #10);
end;

function finalize: Integer;
begin
    createDir('dumps/');
    ExportWikiNOTE_outputLines.saveToFile('dumps/NOTE.wiki');
    ExportWikiNOTE_outputLines.free();
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
    if evByPath(eBySign(note, 'SNAM'), 'Terminal') <> '' then begin
        result := 'This disk shows terminal entries.';
        exit;
    end;

    scene := linkByPath(eBySign(note, 'SNAM'), 'Scene');
    actions := eByPath(scene, 'Actions');

    // Find max stage (and validate their values)
    maxStage := 0;
    for i := 0 to eCount(actions) - 1 do begin
        startStage := strToInt(evBySign(eByIndex(actions, i), 'SNAM'));
        endStage := strToInt(evBySign(eByIndex(actions, i), 'ENAM'));

        if startStage < 0 then begin
            addMessage('ERROR - Negative ENAM');
            result := 'ERROR';
            exit;
        end;

        if startStage > endStage then begin
            addMessage('ERROR - ENAM greater than SNAM');
            result := 'ERROR';
            exit;
        end;

        if endStage > maxStage then begin
            maxStage := endStage;
        end;
    end;

    // Allocate TList
    actionList := TList.create();
    for i := 0 to maxStage do begin
        actionList.add(NULL);
    end;

    // Populate TList
    for i := 0 to eCount(actions) - 1 do begin
        startStage := strToInt(evBySign(eByIndex(actions, i), 'SNAM'));

        actionList.delete(startStage);
        actionList.insert(startStage, eByIndex(actions, i));
    end;

    // Iterate TList to build transcript
    result := '{{Transcript|text=' + #10;

    for i := 0 to maxStage do begin
        if evBySign(objectToElement(actionList.items[i]), 'DATA') <> '' then begin
            result := result
                + getTopicDialogue(linkBySign(objectToElement(actionList.items[i]), 'DATA'))
                + #10 + #10;
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
    if signature(topic) <> 'DIAL' then begin
        addMessage('ERROR - Unexpected signature: ' + signature(topic));
        result := 'ERROR';
        exit;
    end;

    if eCount(childGroup(topic)) <> 1 then begin
        addMessage('ERROR - Unexpected no. of children');
        result := 'ERROR';
        exit;
    end;

    // Add speaker at start of paragraph
    speaker := evBySign(linkBySign(eByIndex(childGroup(topic), 0), 'ANAM'), 'FULL');
    if speaker = '' then begin
        speaker := evBySign(linkBySign(eByIndex(childGroup(topic), 0), 'ANAM'), 'EDID');
    end;
    if (speaker <> '_NPC_NoLines') and (speaker <> ExportWikiNOTE_lastSpeaker) then begin
        result := result + '''''''' + speaker + ''''''': ';
    end;
    ExportWikiNOTE_lastSpeaker := speaker;

    // Add lines of paragraph
    lines := eByPath(eByIndex(childGroup(topic), 0), 'Responses');
    for i := 0 to eCount(lines) do begin
        line := escapeHTML(trim(evBySign(eByIndex(lines, i), 'NAM1')));
        comment := escapeHTML(trim(evBySign(eByIndex(lines, i), 'NAM2')));
        comment := stringReplace(comment, '"', '&quot;', [rfReplaceAll]);

        if trim(comment) = '' then begin
            if (result = '') and (pos('*', line) = 1) then begin
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
