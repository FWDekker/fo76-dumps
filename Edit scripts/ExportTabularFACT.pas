unit Exp_ExportTabularFACT;

uses ExportCore,
     ExportTabularCore;


var ExportTabularFACT_outputLines: TStringList;


function initialize: Integer;
begin
    ExportTabularFACT_outputLines := TStringList.create;
    ExportTabularFACT_outputLines.add('"File", "Form ID", "Editor ID", "Relations", "Is vendor", ' +
                                      '"Refresh rate (days)", "Bottlecap range", "Opening hours (24h clock)", ' +
                                      '"Buys stolen", "Buys non-stolen", "Buys non-list", "Items"');
end;

function canProcess(e: IInterface): Boolean;
begin
    result := signature(e) = 'FACT';
end;

function process(fact: IInterface): Integer;
var venc: IInterface;
    venr: IInterface;
    veng: IInterface;
    venv: IInterface;
    outputString: String;
    isVendor: Boolean;
    bottlecapRange: String;
    itemList: String;
begin
    if not canProcess(fact) then begin
        addMessage('Warning: ' + name(fact) + ' is not a FACT. Entry was ignored.');
        exit;
    end;

    venc := linkBySign(fact, 'VENC');
    venr := linkBySign(fact, 'VENR');
    veng := linkBySign(fact, 'VENG');
    venv := eBySign(fact, 'VENV');

    outputString :=
        escapeCsvString(getFileName(getFile(fact))) + ', ' +
        escapeCsvString(stringFormID(fact)) + ', ' +
        escapeCsvString(evBySign(fact, 'EDID')) + ', ' +
        escapeCsvString(getFlatRelationList(fact)) + ', ';

    if assigned(venc) then begin
        outputString := outputString +
            escapeCsvString('True') + ', ' +
            escapeCsvString(parseFloatToInt(evBySign(venr, 'FLTV'))) + ', ' +
            escapeCsvString(parseFloatToInt(evBySign(veng, 'NAM5')) + '-' + parseFloatToInt(evBySign(veng, 'NAM6'))) + ', ' +
            escapeCsvString(evByPath(venv, 'Start Hour') + '-' + evByPath(venv, 'End Hour')) + ', ' +
            escapeCsvString(evByPath(venv, 'Buys Stolen Items')) + ', ' +
            escapeCsvString(evByPath(venv, 'Buys NonStolen Items')) + ', ' +
            escapeCsvString(evByPath(venv, 'Buy/Sell Everything Not In List?')) + ', ' +
            escapeCsvString(getFlatContainerItemList(linkBySign(linkBySign(fact, 'VENC'), 'NAME'), TStringList.create));
    end else begin
        outputString := outputString +
            escapeCsvString('False') + ', ' +
            escapeCsvString('') + ', ' +
            escapeCsvString('') + ', ' +
            escapeCsvString('') + ', ' +
            escapeCsvString('') + ', ' +
            escapeCsvString('') + ', ' +
            escapeCsvString('') + ', ' +
            escapeCsvString('');
    end;

    ExportTabularFACT_outputLines.add(outputString);
end;

function finalize: Integer;
begin
    createDir('dumps/');
    ExportTabularFACT_outputLines.saveToFile('dumps/FACT.csv');
end;


function getFlatRelationList(fact: IInterface): String;
var i: Integer;
    relations: IInterface;
    relation: IInterface;
    relationFaction: IInterface;
begin
    result := ',';

    relations := eByPath(fact, 'Relations');
    for i := 0 to eCount(relations) - 1 do begin
        relation := eByIndex(relations, i);
        relationFaction := linksTo(eByPath(relation, 'Faction'));
        result := result
            + evBySign(relationFaction, 'EDID')
            + ' (' + stringFormID(relationFaction) + ')'
            + ' (' + evByPath(relation, 'Group Combat Reaction') + ')'
            + ',';
    end;
end;


function getFlatContainerItemList(cont: IInterface; items: TStringList): String;
var i: Integer;
    entries: IInterface;
    entry: IInterface;
    item: IInterface;
begin
    result := ',';

    entries := eByPath(cont, 'Items');
    for i := 0 to eCount(entries) - 1 do begin
        entry := eBySign(eByIndex(entries, i), 'CNTO');
        item := linkByPath(entry, 'Item');

        if signature(item) = 'LVLI' then begin
            result := result + getFlatLeveledItemList(item, items);
        end else begin
            result := result + getFlatItem(item, items);
        end;
    end;
end;

function getFlatLeveledItemList(lvli: IInterface; items: TStringList): String;
var i: Integer;
    entries: IInterface;
    entry: IInterface;
    lvlo: IInterface;
    item: IInterface;
begin
    entries := eByPath(lvli, 'Leveled List Entries');
    for i := 0 to eCount(entries) - 1 do begin
        entry := eByIndex(entries, i);

        lvlo := eByIndex(eBySign(entry, 'LVLO'), 0);
        if name(lvlo) = 'Base Data' then begin
            item := linkByPath(lvlo, 'Reference');
        end else begin
            item := linksTo(lvlo);
        end;

        if signature(item) = 'LVLI' then begin
            result := result + getFlatLeveledItemList(item, items);
        end else begin
            result := result + getFlatItem(item, items);
        end;
    end;
end;

function getFlatItem(item: IInterface; items: TStringList): String;
begin
    if items.indexOf(stringFormID(item)) < 0 then begin
        items.add(stringFormID(item));
        result := result
            + evBySign(item, 'FULL')
            + ' (' + stringFormID(item) + ')'
            + ',';
    end;
end;


end.
