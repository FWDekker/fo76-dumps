unit ExportWikiTERM;

uses ExportCore,
     ExportWikiCore;


var outputLines: TStringList;
    visitHistory: TStringList;


function initialize: Integer;
begin
    outputLines := TStringList.create;
    visitHistory := TStringList.create;
end;

function process(e: IInterface): Integer;
begin
    if (signature(e) <> 'TERM') then
    begin
        addMessage('Error: ' + name(e) + ' is not a TERM.');
        addMessage('Script aborted.');
        exit;
    end;

    if (not isReferencedBy(e, 'REFR')) then
    begin
        exit;
    end;

    visitHistory.clear();

    outputLines.add('==' + evBySignature(e, 'FULL') + ' (' + stringFormID(e) + ')==');
    outputLines.add('{{Transcript|text=');
    outputLines.add('Welcome to ROBCO Industries (TM) Termlink');
    outputLines.add(escapeHTML(trim(evBySignature(e, 'WNAM'))));
    outputLines.add('}}');
    outputLines.add('');
    writeTerminalContents(e, 0);
    outputLines.add(#10);
end;

function finalize: Integer;
begin
    createDir('dumps/');
    outputLines.saveToFile('dumps/TERM.wiki');
end;


function writeTerminalContents(e: IInterface; depth: Integer): String;
var body: IInterface;
    bodyItem: IInterface;

    menu: IInterface;
    menuItem: IInterface;
    menuItemType: String;

    i: Integer;
begin
    visitHistory.add(stringFormID(e));

    body := eByPath(e, 'Body Text');
    for i := 0 to eCount(body) - 1 do
    begin
        bodyItem := eByIndex(body, i);
        outputLines.add(escapeHTML(evBySignature(bodyItem, 'BTXT')));
    end;

    menu := eByPath(e, 'Menu Items');
    for i := 0 to eCount(menu) - 1 do
    begin
        menuItem := eByIndex(menu, i);
        menuItemType := evBySignature(menuItem, 'ANAM');

        if (eCount(eByPath(menuItem, 'Conditions')) > 0) then
        begin
            outputLines.add('{{Info: The following header is conditional}}');
        end;

        if (menuItemType = 'Display Text') then
        begin
            outputLines.add(escapeHTML(createWikiHeader(evBySignature(menuItem, 'ITXT'), depth + 1)));
            outputLines.add('{{Transcript|text=');
            outputLines.add(escapeHTML(trim(evBySignature(menuItem, 'UNAM'))));
            outputLines.add('}}');
            outputLines.add('');
        end
        else if (menuItemType = 'Submenu - Terminal') then
        begin
            if (visitHistory.indexOf(stringFormID(linksTo(eBySignature(menuItem, 'TNAM')))) >= 0) then
            begin
                if (evBySignature(menuItem, 'RNAM') <> '') then
                begin
                    outputLines.add(escapeHTML(createWikiHeader(evBySignature(menuItem, 'ITXT'), depth + 1)));
                    outputLines.add(escapeHTML(trim(evBySignature(menuItem, 'RNAM'))));
                end;
            end
            else
            begin
                outputLines.add(escapeHTML(createWikiHeader(evBySignature(menuItem, 'ITXT'), depth + 1)));
                writeTerminalContents(linksTo(eBySignature(menuItem, 'TNAM')), depth + 1);
            end;
        end
        else if (menuItemType = 'Submenu - Return to Top Level') then
        begin
            // Do nothing
        end
        else if (menuItemType = 'Submenu - Force Redraw') then
        begin
            // Do nothing
        end
        else if (menuItemType = 'Display Image') then
        begin
            outputLines.add('{{Image: ' + evBySignature(menuItem, 'VNAM') + '}}');
        end
        else
        begin
            addMessage('Warning: Unexpected menu item type `' + menuItemType + '`');

            outputLines.add(escapeHTML(createWikiHeader(evBySignature(menuItem, 'ITXT'), depth + 1)));
            outputLines.add('{{Error: Unexpected menu item type}}');
        end;
    end;

    visitHistory.delete(visitHistory.count - 1);
end;


end.
