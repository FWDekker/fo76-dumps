unit ExportWikiTERM;

uses ExportCore,
     ExportWikiCore;


var ExportWikiTERM_outputLines: TStringList;
    ExportWikiTERM_visitHistory: TStringList;


function initialize: Integer;
begin
    ExportWikiTERM_outputLines := TStringList.create;
    ExportWikiTERM_visitHistory := TStringList.create;
end;

function canProcess(e: IInterface): Boolean;
begin
    result := signature(e) = 'TERM';
end;

function process(term: IInterface): Integer;
begin
    if not canProcess(term) then begin
        addMessage('Warning: ' + name(term) + ' is not a TERM. Entry was ignored.');
        exit;
    end;

    if not isReferencedBy(term, 'REFR') then begin
        exit;
    end;

    ExportWikiTERM_visitHistory.clear();

    ExportWikiTERM_outputLines.add('==[' + getFileName(getFile(term)) + '] ' + evBySignature(term, 'FULL') +
                                   ' (' + stringFormID(term) + ')==');
    ExportWikiTERM_outputLines.add('{{Transcript|text=');
    ExportWikiTERM_outputLines.add('Welcome to ROBCO Industries (TM) Termlink');
    ExportWikiTERM_outputLines.add(escapeHTML(trim(evBySignature(term, 'WNAM'))));
    ExportWikiTERM_outputLines.add('}}');
    ExportWikiTERM_outputLines.add('');
    writeTerminalContents(term, 0);
    ExportWikiTERM_outputLines.add(#10);
end;

function finalize: Integer;
begin
    createDir('dumps/');
    ExportWikiTERM_outputLines.saveToFile('dumps/TERM.wiki');
end;


function writeTerminalContents(e: IInterface; depth: Integer): String;
var body: IInterface;
    bodyItem: IInterface;

    menu: IInterface;
    menuItem: IInterface;
    menuItemType: String;

    i: Integer;
begin
    ExportWikiTERM_visitHistory.add(stringFormID(e));

    body := eByPath(e, 'Body Text');
    for i := 0 to eCount(body) - 1 do begin
        bodyItem := eByIndex(body, i);
        ExportWikiTERM_outputLines.add(escapeHTML(evBySignature(bodyItem, 'BTXT')));
    end;

    menu := eByPath(e, 'Menu Items');
    for i := 0 to eCount(menu) - 1 do begin
        menuItem := eByIndex(menu, i);
        menuItemType := evBySignature(menuItem, 'ANAM');

        if eCount(eByPath(menuItem, 'Conditions')) > 0 then begin
            ExportWikiTERM_outputLines.add('{{Info: The following header is conditional}}');
        end;

        if menuItemType = 'Display Text' then begin
            ExportWikiTERM_outputLines.add(escapeHTML(createWikiHeader(evBySignature(menuItem, 'ITXT'), depth + 1)));
            ExportWikiTERM_outputLines.add('{{Transcript|text=');
            ExportWikiTERM_outputLines.add(escapeHTML(trim(evBySignature(menuItem, 'UNAM'))));
            ExportWikiTERM_outputLines.add('}}');
            ExportWikiTERM_outputLines.add('');
        end else if menuItemType = 'Submenu - Terminal' then begin
            if ExportWikiTERM_visitHistory
                .indexOf(stringFormID(linksTo(eBySignature(menuItem, 'TNAM')))) >= 0 then begin
                if evBySignature(menuItem, 'RNAM') <> '' then begin
                    ExportWikiTERM_outputLines
                        .add(escapeHTML(createWikiHeader(evBySignature(menuItem, 'ITXT'), depth + 1)));
                    ExportWikiTERM_outputLines.add(escapeHTML(trim(evBySignature(menuItem, 'RNAM'))));
                end;
            end else begin
                ExportWikiTERM_outputLines
                    .add(escapeHTML(createWikiHeader(evBySignature(menuItem, 'ITXT'), depth + 1)));
                writeTerminalContents(linksTo(eBySignature(menuItem, 'TNAM')), depth + 1);
            end;
        end else if menuItemType = 'Submenu - Return to Top Level' then begin
            // Do nothing
        end else if menuItemType = 'Submenu - Force Redraw' then begin
            // Do nothing
        end else if menuItemType = 'Display Image' then begin
            ExportWikiTERM_outputLines.add('{{Image: ' + evBySignature(menuItem, 'VNAM') + '}}');
        end else begin
            addMessage('Warning: Unexpected menu item type `' + menuItemType + '`');

            ExportWikiTERM_outputLines.add(escapeHTML(createWikiHeader(evBySignature(menuItem, 'ITXT'), depth + 1)));
            ExportWikiTERM_outputLines.add('{{Error: Unexpected menu item type}}');
        end;
    end;

    ExportWikiTERM_visitHistory.delete(ExportWikiTERM_visitHistory.count - 1);
end;


end.
