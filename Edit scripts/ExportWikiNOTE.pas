unit ExportWikiNOTE;

uses ExportCore,
     ExportWikiCore;


var ExportWikiNOTE_outputLines: TStringList;
    ExportWikiNOTE_lastSpeaker: String;


function initialize(): Integer;
begin
    ExportWikiNOTE_outputLines := TStringList.create();
end;

function process(el: IInterface): Integer;
begin
    if signature(el) <> 'NOTE' then begin exit; end;

    _process(el);
end;

function _process(note: IInterface): Integer;
begin
    ExportWikiNOTE_lastSpeaker := '';

    ExportWikiNOTE_outputLines.add(
        '==[' + getFileName(getFile(note)) + '] ' +
        getEditValue(elementBySignature(note, 'FULL')) + '=='
    );
    ExportWikiNOTE_outputLines.add('Form ID:   ' + stringFormID(note));
    ExportWikiNOTE_outputLines.add('Editor ID: ' + getEditValue(elementBySignature(note, 'EDID')));
    ExportWikiNOTE_outputLines.add('Weight:    ' + getEditValue(elementByPath(note, 'DATA\Weight')));
    ExportWikiNOTE_outputLines.add('Value:     ' + getEditValue(elementByPath(note, 'DATA\Value')));
    ExportWikiNOTE_outputLines.add('Transcript: ' + #10 + getNoteDialogue(note) + #10 + #10);
end;

function finalize(): Integer;
begin
    createDir('dumps/');
    ExportWikiNOTE_outputLines.saveToFile('dumps/NOTE.wiki');
    ExportWikiNOTE_outputLines.free();
end;


function getNoteDialogue(note: IInterface): String;
var action: IInterface;
    actions: IInterface;
    actionList: TList;

    maxStage: Integer;
    startStage: Integer;
    endStage: Integer;

    i: Integer;
begin
    if getEditValue(elementByPath(note, 'SNAM\Terminal')) <> '' then begin
        result :=
            'This disk shows terminal entries from `TERM:' +
            stringFormID(linksTo(elementByPath(note, 'SNAM\Terminal'))) +
            '`.';
        exit;
    end;

    actions := elementByName(linksTo(elementByPath(note, 'SNAM\Scene')), 'Actions');

    // Find max stage (and validate their values)
    maxStage := 0;
    for i := 0 to elementCount(actions) - 1 do begin
        action := elementByIndex(actions, i);
        startStage := strToInt(getEditValue(elementBySignature(action, 'SNAM')));
        endStage := strToInt(getEditValue(elementBySignature(action, 'ENAM')));

        if startStage < 0 then begin
            result := addError('Negative ENAM');
            exit;
        end;

        if startStage > endStage then begin
            result := addError('ENAM greater than SNAM');
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
    for i := 0 to elementCount(actions) - 1 do begin
        startStage := strToInt(getEditValue(elementBySignature(elementByIndex(actions, i), 'SNAM')));

        actionList.delete(startStage);
        actionList.insert(startStage, elementByIndex(actions, i));
    end;

    // Iterate TList to build transcript
    result := '{{Transcript|text=' + #10;

    for i := 0 to maxStage do begin
        if getEditValue(elementBySignature(objectToElement(actionList.items[i]), 'DATA')) <> '' then begin
            result := result +
                getTopicDialogue(linksTo(elementBySignature(objectToElement(actionList.items[i]), 'DATA'))) +
                #10 + #10;
        end;
    end;
    delete(result, length(result) - 1, 1);  // Remove trailing newline

    // Finalize
    actionList.free();
    result := result + '}}';
end;

function getTopicDialogue(topic: IInterface): String;
var speakerRecord: IInterface;
    speaker: String;
    lines: IInterface;
    line: String;
    comment: String;

    i: Integer;
begin
    if signature(topic) <> 'DIAL' then begin
        result := addError('Unexpected signature: ' + signature(topic));
        exit;
    end;

    if elementCount(childGroup(topic)) = 0 then begin
        result := addError('Topic has 0 children');
        exit;
    end;

    if elementCount(childGroup(topic)) <> 1 then begin
        // Non-fatal error
        result := addError('Manually check `DIAL:' + stringFormID(topic) + '` for cut content lines');
    end;

    // Add speaker at start of paragraph
    speakerRecord := linksTo(elementBySignature(elementByIndex(childGroup(topic), 0), 'ANAM'));
    speaker := getEditValue(elementBySignature(speakerRecord, 'FULL'));
    if speaker = '' then begin
        speaker := getEditValue(elementBySignature(speakerRecord, 'EDID'));
    end;
    if (speaker <> '_NPC_NoLines') and (speaker <> ExportWikiNOTE_lastSpeaker) then begin
        result := result + '''''''' + speaker + ''''''': ';
    end;
    ExportWikiNOTE_lastSpeaker := speaker;

    // Add lines of paragraph
    lines := elementByName(elementByIndex(childGroup(topic), 0), 'Responses');
    for i := 0 to elementCount(lines) do begin
        line := escapeHTML(trim(getEditValue(elementBySignature(elementByIndex(lines, i), 'NAM1'))));
        comment := escapeHTML(trim(getEditValue(elementBySignature(elementByIndex(lines, i), 'NAM2'))));
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
