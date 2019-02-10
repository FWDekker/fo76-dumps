unit ExportWikiTERM;

uses ExportWikiCore;


var
    outputLines: TStringList;
    visitHistory: TStringList;


function Initialize: integer;
begin
    outputLines := TStringList.Create;
    visitHistory := TStringList.Create;
end;

function Process(e: IInterface): integer;
begin
    if (Signature(e) <> 'TERM') then
    begin
        AddMessage('Error: ' + Name(e) + ' is not a TERM.');
        AddMessage('Script aborted.');
        Exit;
    end;

    if (not IsReferencedBy(e, 'REFR')) then
    begin
        Exit;
    end;

    visitHistory.Clear();

    outputLines.Add('==' + GetEditValue(ElementBySignature(e, 'FULL')) + ' (' + LowerCase(IntToHex(FormID(e), 8)) + ')==');
    outputLines.Add('{{Transcript|text=');
    outputLines.Add('Welcome to ROBCO Industries (TM) Termlink');
    outputLines.Add(EscapeHTML(Trim(GetEditValue(ElementBySignature(e, 'WNAM')))));
    outputLines.Add('}}');
    outputLines.Add('');
    WriteTerminalContents(e, 0);
    outputLines.Add(#10);
end;

function Finalize: integer;
begin
    CreateDir('dumps/');
    outputLines.SaveToFile('dumps/TERM.wiki');
end;


function WriteTerminalContents(e: IInterface; depth: integer): string;
var
    body: IInterface;
    bodyItem: IInterface;

    menu: IInterface;
    menuItem: IInterface;
    menuItemType: string;

    i: integer;
begin
    visitHistory.Add(IntToHex(FormID(e), 8));

    body := ElementByPath(e, 'Body Text');
    for i := 0 to ElementCount(body) - 1 do
    begin
        bodyItem := ElementByIndex(body, i);
        outputLines.Add(EscapeHTML(GetEditValue(ElementBySignature(bodyItem, 'BTXT'))));
    end;

    menu := ElementByPath(e, 'Menu Items');
    for i := 0 to ElementCount(menu) - 1 do
    begin
        menuItem := ElementByIndex(menu, i);
        menuItemType := GetEditValue(ElementBySignature(menuItem, 'ANAM'));

        if (ElementCount(ElementByPath(menuItem, 'Conditions')) > 0) then
        begin
            outputLines.Add('{{Info: The following header is conditional}}');
        end;

        if (menuItemType = 'Display Text') then
        begin
            outputLines.Add(EscapeHTML(CreateWikiHeader(GetEditValue(ElementBySignature(menuItem, 'ITXT')), depth + 1)));
            outputLines.Add('{{Transcript|text=');
            outputLines.Add(EscapeHTML(Trim(GetEditValue(ElementBySignature(menuItem, 'UNAM')))));
            outputLines.Add('}}');
            outputLines.Add('');
        end
        else if (menuItemType = 'Submenu - Terminal') then
        begin
            if (visitHistory.IndexOf(IntToHex(FormID(LinksTo(ElementBySignature(menuItem, 'TNAM'))), 8)) >= 0) then
            begin
                if (GetEditValue(ElementBySignature(menuItem, 'RNAM')) <> '') then
                begin
                    outputLines.Add(EscapeHTML(CreateWikiHeader(GetEditValue(ElementBySignature(menuItem, 'ITXT')), depth + 1)));
                    outputLines.Add(EscapeHTML(Trim(GetEditValue(ElementBySignature(menuItem, 'RNAM')))));
                end;
            end
            else
            begin
                outputLines.Add(EscapeHTML(CreateWikiHeader(GetEditValue(ElementBySignature(menuItem, 'ITXT')), depth + 1)));
                WriteTerminalContents(LinksTo(ElementBySignature(menuItem, 'TNAM')), depth + 1);
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
            outputLines.Add('{{Image: ' + GetEditValue(ElementBySignature(menuItem, 'VNAM')) + '}}');
        end
        else
        begin
            AddMessage('Warning: Unexpected menu item type `' + menuItemType + '`');

            outputLines.Add(EscapeHTML(CreateWikiHeader(GetEditValue(ElementBySignature(menuItem, 'ITXT')), depth + 1)));
            outputLines.Add('{{Error: Unexpected menu item type}}');
        end;
    end;

    visitHistory.Delete(visitHistory.Count - 1);
end;


end.
