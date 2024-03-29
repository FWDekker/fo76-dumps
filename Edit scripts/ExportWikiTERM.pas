unit ExportWikiTERM;

uses ExportCore,
     ExportWikiCore,
     ExportLargeFile;


var ExportWikiTERM_buffer: TStringList;
var ExportWikiTERM_size: Integer;
var ExportWikiTERM_maxSize: Integer;


function initialize(): Integer;
begin
    ExportWikiTERM_buffer := TStringList.create();
    ExportWikiTERM_size := 0;
    ExportWikiTERM_maxSize := 10000000;

    createDir('dumps/');
    clearLargeFiles('dumps/TERM.wiki');
end;

function canProcess(el: IInterface): Boolean;
begin
    result := signature(el) = 'TERM';
end;

function process(term: IInterface): Integer;
var header: String;
    contents: String;
    history: TStringList;
begin
    if not canProcess(term) then begin
        addWarning(name(term) + ' is not a TERM. Entry was ignored.');
        exit;
    end;

    header := escapeWiki(trim(evBySign(term, 'WNAM')));
    if not (header = '') then begin
        header := header + #10;
    end;

    history := TStringList.create();
    contents := trim(getTerminalContents(term, history));
    history.free();
    if not (contents = '') then begin
        contents := '' + #10 + contents + #10 + #10;
    end;

    appendLargeFile('dumps/TERM.wiki', ExportWikiTERM_buffer, ExportWikiTERM_size, ExportWikiTERM_maxSize,
          '==[' + getFileName(getFile(term)) + '] ' + evBySign(term, 'FULL') + ' (' + stringFormID(term) + ')==' + #10
        + '{{Transcript|text=' + #10
        + 'Welcome to ROBCO Industries (TM) Termlink' + #10
        + header
        + '}}' + #10
        + contents
    );
end;

function finalize(): Integer;
begin
    flushLargeFile('dumps/TERM.wiki', ExportWikiTERM_buffer, ExportWikiTERM_size);
    freeLargeFile(ExportWikiTERM_buffer);
end;


function getTerminalContents(el: IInterface; history: TStringList): String;
var body: IInterface;
    bodyItem: IInterface;

    menu: IInterface;
    menuItem: IInterface;
    menuItemType: String;

    i: Integer;
begin
    history.add(stringFormID(el));

    body := eByName(el, 'Body Text');
    for i := 0 to eCount(body) - 1 do begin
        bodyItem := eByIndex(body, i);

        if eCount(eByName(bodyItem, 'Conditions')) > 0 then begin
            result := result + '{{Info: The following body is conditional}}' + #10;
        end;
        result := result
            + '{{Transcript|text=' + #10
            + escapeWiki(trim(evBySign(bodyItem, 'BTXT'))) + #10
            + '}}' + #10;
    end;

    menu := eByName(el, 'Menu Items');
    for i := 0 to eCount(menu) - 1 do begin
        menuItem := eByIndex(menu, i);
        menuItemType := evBySign(menuItem, 'ANAM');

        if (menuItemType = 'Submenu - Return to Top Level') or (menuItemType = 'Submenu - Force Redraw') then begin
            continue;
        end;

        result := result + #10;
        if eCount(eByPath(menuItem, 'Conditions')) > 0 then begin
            result := result + '{{Info: The following header is conditional}}' + #10;
        end;

        if menuItemType = 'Display Text' then begin
            result := result
                + createWikiHeader(escapeWiki(evBySign(menuItem, 'ITXT')), history.count) + #10
                + '{{Transcript|text=' + #10
                + escapeWiki(trim(evBySign(menuItem, 'UNAM'))) + #10
                + '}}' + #10;
        end else if menuItemType = 'Submenu - Terminal' then begin
            if history.indexOf(stringFormID(linkBySign(menuItem, 'TNAM'))) >= 0 then begin
                if evBySign(menuItem, 'RNAM') <> '' then begin
                    result := result
                        + createWikiHeader(escapeWiki(evBySign(menuItem, 'ITXT')), history.count) + #10
                        + '{{Transcript|text=' + #10
                        + trim(escapeWiki(evBySign(menuItem, 'RNAM'))) + #10
                        + '}}' + #10;
                end;
            end else begin
                result := result
                    + createWikiHeader(escapeWiki(evBySign(menuItem, 'ITXT')), history.count) + #10
                    + trim(getTerminalContents(linkBySign(menuItem, 'TNAM'), history)) + #10;
            end;
        end else if menuItemType = 'Display Image' then begin
            result := result + '{{Image: ' + evBySign(menuItem, 'VNAM') + '}}' + #10;
        end else begin
            // Non-fatal error
            result := result
                + createWikiHeader(escapeWiki(evBySign(menuItem, 'ITXT')), history.count) + #10
                + addError('Unexpected menu item type `' + menuItemType + '`') + #10;
        end;
    end;
end;


end.
