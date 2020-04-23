(**
 * Converts lists into flat lists, aka JSON arrays.
 *)
unit ExportFlatList;



(**
 * Returns the keywords of [e] as a comma-separated list of editor IDs.
 *
 * @param e the element to return the keywords of
 * @return the keywords of [e] as a comma-separated list of editor IDs
 *)
function getFlatKeywordList(e: IInterface): String;
var i: Integer;
    keywords: IInterface;
    resultList: TStringList;
begin
    resultList := TStringList.create();

    keywords := eBySign(eByPath(e, 'Keywords'), 'KWDA');
    for i := 0 to eCount(keywords) - 1 do begin
        resultList.add(evBySign(linkByIndex(keywords, i), 'EDID'));
    end;

    resultList.sort();
    result := listToJson(resultList);
    resultList.free();
end;

(**
 * Returns the factions of [e] as a comma-separated list of editor IDs.
 *
 * @param e the element to return the factions of
 * @return the factions of [e] as a comma-separated list of editor IDs
 *)
function getFlatFactionList(e: IInterface): String;
var i: Integer;
    factions: IInterface;
    faction: IInterface;
    resultList: TStringList;
begin
    resultList := TStringList.create();

    factions := eByPath(e, 'Factions');
    for i := 0 to eCount(factions) - 1 do begin
        faction := eByIndex(factions, i);
        resultList.add(evBySign(linkByPath(faction, 'Faction'), 'EDID'));
    end;

    resultList.sort();
    result := listToJson(resultList);
    resultList.free();
end;

(**
 * Returns the components of [e] as a comma-separated list of editor IDs and counts.
 *
 * @param e the element to return the components of
 * @return the components of [e] as a comma-separated list of editor IDs and counts
 *)
function getFlatComponentList(e: IInterface): String;
var i: Integer;
    components: IInterface;
    component: IInterface;
    resultList: TStringList;
begin
    resultList := TStringList.create();

    components := eBySign(e, 'FVPA');
    for i := 0 to eCount(components) - 1 do begin
        component := eByIndex(components, i);
        resultList.add(
              evBySign(linkByPath(component, 'Component'), 'EDID')
            + ' (' + intToStr(evByPath(component, 'Count')) + ')'
        );
    end;

    resultList.sort();
    result := listToJson(resultList);
    resultList.free();
end;

(**
 * Returns the perks of [e] as a comma-separated list.
 *
 * Each perk is expressed as a pair of the perk's editor ID and the perk's rank, separated by an equals sign.
 *
 * @param e the element to return the perks of
 * @return the perks of [e] as a comma-separated list
 *)
function getFlatPerkList(e: IInterface): String;
var i: Integer;
    perks: IInterface;
    perk: IInterface;
    resultList: TStringList;
begin
    resultList := TStringList.create();

    perks := eByPath(e, 'Perks');
    for i := 0 to eCount(perks) - 1 do begin
        perk := eByIndex(perks, i);
        resultList.add(evBySign(linkByPath(perk, 'Perk'), 'EDID') + '=' + evByPath(perk, 'Rank'));
    end;

    resultList.sort();
    result := listToJson(resultList);
    resultList.free();
end;

(**
 * Returns the properties of [e] as a comma-separated list.
 *
 * Each property is expressed as a pair of the property's editor ID and either the property's value or the property's
 * curve table's editor ID, separated by an equals sign.
 *
 * @param e the element to return the properties of
 * @return the properties of [e] as a comma-separated list
 *)
function getFlatPropertyList(e: IInterface): String;
var i: Integer;
    props: IInterface;
    prop: IInterface;
    avEdid: String;
    avValue: String;
    resultList: TStringList;
begin
    resultList := TStringList.create();

    props := eBySign(e, 'PRPS');
    for i := 0 to eCount(props) - 1 do begin
        prop := eByIndex(props, i);
        avEdid := evBySign(linkByPath(prop, 'Actor Value'), 'EDID');

        if assigned(linkByPath(prop, 'Curve Table')) then begin
            avValue := evBySign(linkByPath(prop, 'Curve Table'), 'EDID');
        end else begin
            avValue := evByPath(prop, 'Value');
        end;
        try
            avValue := floatToStr(strToFloat(avValue)); // Remove unnecessary decimals
        except end;

        resultList.add(avEdid + '=' + avValue);
    end;

    resultList.sort();
    result := listToJson(resultList);
    resultList.free();
end;

(**
 * Returns the (iterable) children of [list] as a comma-separated list, sorted alphabetically by the child strings.
 *
 * Each child is simply converted to a string.
 *
 * @param e the element to return the children of
 * @return the children of [list] as a comma-separated list
 *)
function getFlatChildList(list: IInterface): String;
var i: Integer;
    resultList: TStringList;
begin
    resultList := TStringList.create();

    for i := 0 to eCount(list) - 1 do begin
        resultList.add(escapeQuotes(evByIndex(list, i)));
    end;

    resultList.sort();
    result := listToJson(resultList);
    resultList.free();
end;

(**
 * Returns the (iterable) children of [list] as a comma-separated list.
 *
 * Each child is simply converted to a string.
 *
 * @param e the element to return the children of
 * @return the children of [list] as a comma-separated list
 *)
function getFlatUnsortedChildList(list: IInterface): String;
var i: Integer;
    resultList: TStringList;
begin
    resultList := TStringList.create();

    for i := 0 to eCount(list) - 1 do begin
        resultList.add(escapeQuotes(evByIndex(list, i)));
    end;

    result := listToJson(resultList);
    resultList.free();
end;

(**
 * Returns the (iterable) children of [list] as a comma-separated list, sorted alphabetically by the child names.
 *
 * Each child is simply converted to its `name`.
 *
 * @param e the element to return the children of
 * @return the children of [list] as a comma-separated list
 *)
function getFlatChildNameList(list: IInterface): String;
var i: Integer;
    resultList: TStringList;
begin
    resultList := TStringList.create();

    for i := 0 to eCount(list) - 1 do begin
        resultList.add(escapeQuotes(name(eByIndex(list, i))));
    end;

    resultList.sort();
    result := listToJson(resultList);
    resultList.free();
end;


end.
