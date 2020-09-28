unit ExportTabularFACT;

uses ExportCore,
     ExportTabularCore,
     ExportJson;


var ExportTabularFACT_outputLines: TStringList;


function initialize(): Integer;
begin
    ExportTabularFACT_outputLines := TStringList.create();
    ExportTabularFACT_outputLines.add(
            '"File"'                // Name of the originating ESM
        + ', "Form ID"'             // Form ID
        + ', "Editor ID"'           // Editor ID
        + ', "Name"'                // Full name
        + ', "Relations"'           // Sorted JSON array
        + ', "Is vendor"'           // `True` if and only if this is a vendor faction
        + ', "Refresh rate (days)"' // If vendor, the number of days after which the inventory is refreshed
        + ', "Bottlecap range"'     // If vendor, the number of bottlecaps owned by the faction, formatted as
                                    // `[minimum value]-[maximum value]`
        + ', "Opening hours"'       // Hours of the day at which the vendors are available for trading, formatted as
                                    // `[earliest hour]-[latest hour]`; both times in 24h format
        + ', "Buys stolen"'         // `True` if and only if vendors of this faction buy stolen items
        + ', "Buys non-stolen"'     // `True` if and only if vendors of this faction buy non-stolen items
        + ', "Buys non-list"'       // `True` if and only if vendors of this faction buy items that are not on
                                    // their list
        + ', "Items"'               // Sorted JSON array of items for sale by vendors of this faction. Each item is
                                    // formatted as `[full name] ([form id])`
    );
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
        addWarning(name(fact) + ' is not a FACT. Entry was ignored.');
        exit;
    end;

    venc := linkBySign(fact, 'VENC');
    venr := linkBySign(fact, 'VENR');
    veng := linkBySign(fact, 'VENG');
    venv := eBySign(fact, 'VENV');

    outputString :=
          escapeCsvString(getFileName(getFile(fact))) + ', '
        + escapeCsvString(stringFormID(fact)) + ', '
        + escapeCsvString(evBySign(fact, 'EDID')) + ', '
        + escapeCsvString(evBySign(fact, 'FULL')) + ', '
        + escapeCsvString(getJsonRelationArray(fact)) + ', ';

    if assigned(venc) then begin
        outputString := outputString
            + '"True", '
            + escapeCsvString(parseFloatToInt(evBySign(venr, 'FLTV'))) + ', '
            + escapeCsvString(parseFloatToInt(evBySign(veng, 'NAM5')) + '-' + parseFloatToInt(evBySign(veng, 'NAM6'))) + ', '
            + escapeCsvString(evByPath(venv, 'Start Hour') + '-' + evByPath(venv, 'End Hour')) + ', '
            + escapeCsvString(evByPath(venv, 'Buys Stolen Items')) + ', '
            + escapeCsvString(evByPath(venv, 'Buys NonStolen Items')) + ', '
            + escapeCsvString(evByPath(venv, 'Buy/Sell Everything Not In List?')) + ', '
            + escapeCsvString(getJsonContainerItemArray(linkBySign(linkBySign(fact, 'VENC'), 'NAME')));
    end else begin
        outputString := outputString
            + '"False", '
            + '"", '
            + '"", '
            + '"", '
            + '"", '
            + '"", '
            + '"", '
            + '""';
    end;

    ExportTabularFACT_outputLines.add(outputString);
end;

function finalize(): Integer;
begin
    createDir('dumps/');
    ExportTabularFACT_outputLines.saveToFile('dumps/FACT.csv');
    ExportTabularFACT_outputLines.free();
end;


(**
 * Returns a JSON array string of all relations that [fact] has to other factions.
 *
 * @param fact  the faction to return relations of
 * @return a JSON array string of all relations that [fact] has to other factions
 *)
function getJsonRelationArray(fact: IInterface): String;
var i: Integer;
    relations: IInterface;
    relation: IInterface;
    relationFaction: IInterface;
    resultList: TStringList;
begin
    resultList := TStringList.create();

    relations := eByPath(fact, 'Relations');
    for i := 0 to eCount(relations) - 1 do begin
        relation := eByIndex(relations, i);
        relationFaction := linksTo(eByPath(relation, 'Faction'));

        resultList.add(
            '{' +
             '"Faction":"'               + escapeJson(evByPath(relation, 'Faction'))               + '"' +
            ',"Group Combat Reaction":"' + escapeJson(evByPath(relation, 'Group Combat Reaction')) + '"' +
            '}'
        );
    end;

    resultList.sort();
    result := listToJsonArray(resultList);
    resultList.free();
end;

(**
 * Returns a JSON array string of all items in [cont].
 *
 * @param cont  the container to return all items from
 * @return a JSON array string of all items in [cont]
 *)
function getJsonContainerItemArray(cont: IInterface): String;
var i: Integer;
    entries: IInterface;
    entry: IInterface;
    item: IInterface;
    itemHistory: TStringList;
    lvliHistory: TStringList;
begin
    itemHistory := TStringList.create();
    lvliHistory := TStringList.create();

    entries := eByPath(cont, 'Items');
    for i := 0 to eCount(entries) - 1 do begin
        entry := eBySign(eByIndex(entries, i), 'CNTO');
        item := eByPath(entry, 'Item');

        if signature(linksTo(item)) = 'LVLI' then begin
            addLeveledItemList(lvliHistory, itemHistory, linksTo(item));
        end else begin
            addItem(itemHistory, item);
        end;
    end;

    itemHistory.sort();
    result := stringListToJsonArray(itemHistory);

    lvliHistory.free();
    itemHistory.free();
end;

(**
 * Recursively adds all items in [lvli] to [itemHistory], using [lvliHistory] as a cache to prevent revisiting branches
 * of the item tree.
 *
 * @param lvliHistory  a list of the form IDs of leveled items that have already been visited
 * @param itemHistory  the list of items to add all items in [lvli] to
 * @param lvli         the leveled item to recursively visit
 *)
procedure addLeveledItemList(lvliHistory: TStringList; itemHistory: TStringList; lvli: IInterface);
var i: Integer;
    entries: IInterface;
    entry: IInterface;
    lvlo: IInterface;
    item: IInterface;
begin
    if lvliHistory.indexOf(stringFormID(lvli)) >= 0 then begin
        exit;
    end;
    lvliHistory.add(stringFormID(lvli));

    entries := eByPath(lvli, 'Leveled List Entries');
    for i := 0 to eCount(entries) - 1 do begin
        entry := eByIndex(entries, i);
        lvlo := eByIndex(eBySign(entry, 'LVLO'), 0);

        if name(lvlo) = 'Base Data' then begin
            item := eByPath(lvlo, 'Reference');
        end else begin
            item := lvlo;
        end;

        if signature(linksTo(item)) = 'LVLI' then begin
            addLeveledItemList(lvliHistory, itemHistory, linksTo(item));
        end else begin
            addItem(itemHistory, item);
        end;
    end;
end;

(**
 * Adds a string representation of [item] to [itemHistory] if it's not already in there.
 *
 * @param itemHistory  the list of items to (potentially) add [item] to
 * @param item         the link to the item to (potentially) add to [itemHistory]
 *)
procedure addItem(itemHistory: TStringList; item: IInterface);
var itemString: String;
begin
    itemString := gev(item);

    if itemHistory.indexOf(itemString) >= 0 then begin
        exit;
    end;
    itemHistory.add(itemString);
end;


end.
