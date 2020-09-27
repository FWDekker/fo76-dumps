(**
 * Export (parts of) records in JSON arrays and objects.
 *)
unit ExportJson;


(***
 *
 * Core functions for JSON serialization.
 *
 **)

(**
 * Escapes all double quotes in [text] by putting a backslash in front of them.
 *
 * @param text  the text to escape
 * @return a quote-escaped version of [text]
 *)
function escapeQuotes(text: String): String;
begin
    result := stringReplace(text, '"', '\"', [rfReplaceAll]);
end;

(**
 * Serializes the list of values into a JSON array.
 *
 * Each list entry is interpreted as a raw value and is not surrounded with quotes.
 *
 * @param list  the list of values to convert to a serialized JSON array
 * @return a serialized JSON array version of [list]
 *)
function listToJsonArray(list: TStringList): String;
var i: Integer;
begin
    if list.count = 0 then begin
        result := '[]';
        exit;
    end;

    result := list[0];
    for i := 1 to list.count - 1 do begin
        result := result + ',' + list[i];
    end;

    result := '[' + result + ']';
end;

(**
 * Serializes the list of strings into a JSON array.
 *
 * Each list entry is interpreted as a string and is therefore surrounded with double quotes as part of serialization.
 *
 * @param list  the list of strings to convert to a serialized JSON array
 * @return a serialized JSON array version of [list]
 *)
function stringListToJsonArray(list: TStringList): String;
var i: Integer;
begin
    for i := 0 to list.count - 1 do begin
        list[i] = '"' + escapeQuotes(list[i]) + '"';
    end;
    result := listToJsonArray(list);
end;

(**
 * Serializes the lists of keys and values into a JSON object.
 *
 * @param keys    the list of keys
 * @param values  the list of associated values
 * @param sorted  whether to sort the entries by key
 * @return a serialized JSON object version of the [keys] and [values]
 *)
function listsToJsonObject(keys: TStringList; values: TStringList; sorted: Boolean): String;
var i: Integer;
    entries: TStringList;
begin
    if keys.count <> values.count then begin
        result := addError('Key count does not match value count');
        exit;
    end;
    if keys.count = 0 then begin
        result := '{}';
        exit;
    end;

    entries := TStringList.create();
    for i := 0 to keys.count - 1 do begin
        entries.add('"' + escapeQuotes(keys[i]) + '": "' + escapeQuotes(values[i]) + '"');
    end;

    if sorted then begin
        entries.sort();
    end;

    result := entries[0];
    for i := 1 to entries.count - 1 do begin
        result := result + ',' + entries[i];
    end;

    result := '{' + result + '}';
end;



(***
 *
 * Domain-specific serialization functions.
 *
 **)

(**
 * Returns the keywords of [e] as a serialized JSON array of editor IDs.
 *
 * @param e  the element to return the keywords of
 * @return the keywords of [e] as a serialized JSON array of editor IDs
 *)
function getJsonKeywordArray(e: IInterface): String;
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
    result := stringListToJsonArray(resultList);
    resultList.free();
end;

(**
 * Returns the factions of [e] as a serialized JSON array of editor IDs.
 *
 * @param e  the element to return the factions of
 * @return the factions of [e] as a serialized JSON array of editor IDs
 *)
function getJsonFactionArray(e: IInterface): String;
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
    result := stringListToJsonArray(resultList);
    resultList.free();
end;

(**
 * Returns the components of [e] as a serialized JSON array of editor IDs and counts.
 *
 * @param e  the element to return the components of
 * @return the components of [e] as a serialized JSON array of editor IDs and counts
 *)
function getJsonComponentArray(e: IInterface): String;
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
    result := stringListToJsonArray(resultList);
    resultList.free();
end;

(**
 * Returns the perks of [e] as a serialized JSON array of editor IDs.
 *
 * @param e  the element to return the perks of
 * @return the perks of [e] as a serialized JSON array of editor IDs
 *)
function getJsonPerkArray(e: IInterface): String;
var i: Integer;
    perks: IInterface;
    perk: IInterface;
    resultList: TStringList;
begin
    resultList := TStringList.create();

    perks := eByPath(e, 'Perks');
    for i := 0 to eCount(perks) - 1 do begin
        perk := eByIndex(perks, i);
        resultList.add(evBySign(linkByPath(perk, 'Perk'), 'EDID'));
    end;

    resultList.sort();
    result := stringListToJsonArray(resultList);
    resultList.free();
end;

(**
 * Returns the properties of [e] as a serialized JSON object.
 *
 * Each property is expressed using the property's editor ID as the key and either the property's value or the
 * property's curve table's editor ID as the value.
 *
 * @param e  the element to return the properties of
 * @return the properties of [e] as a serialized JSON object
 *)
function getJsonPropertyObject(e: IInterface): String;
var i: Integer;
    props: IInterface;
    prop: IInterface;
    avEdid: String;
    avValue: String;
    resultKeys: TStringList;
    resultValues: TStringList;
begin
    resultKeys := TStringList.create();
    resultValues := TStringList.create();

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

        resultKeys.add(avEdid);
        resultValues.add(avValue);
    end;

    // resultList.sort();
    result := listsToJsonObject(resultKeys, resultValues, true);
    resultValues.free();
    resultKeys.free();
end;

(**
 * Returns the (iterable) children of [list] as a serialized JSON array, sorted alphabetically by the child strings.
 *
 * Each child is simply converted to a string.
 *
 * @param e  the element to return the children of
 * @return the children of [list] as a comma-separated list
 *)
function getJsonChildArray(list: IInterface): String;
var i: Integer;
    resultList: TStringList;
begin
    resultList := TStringList.create();

    for i := 0 to eCount(list) - 1 do begin
        resultList.add(evByIndex(list, i));
    end;

    resultList.sort();
    result := stringListToJsonArray(resultList);
    resultList.free();
end;

(**
 * Returns the (iterable) children of [list] as a serialized JSON array.
 *
 * Each child is simply converted to a string.
 *
 * @param e  the element to return the children of
 * @return the children of [list] as a serialized JSON array
 *)
function getJsonUnsortedChildArray(list: IInterface): String;
var i: Integer;
    resultList: TStringList;
begin
    resultList := TStringList.create();

    for i := 0 to eCount(list) - 1 do begin
        resultList.add(evByIndex(list, i));
    end;

    result := stringListToJsonArray(resultList);
    resultList.free();
end;

(**
 * Returns the (iterable) children of [list] as a serialized JSON array, sorted alphabetically by the child names.
 *
 * Each child is simply converted to its `name`.
 *
 * @param e  the element to return the children of
 * @return the children of [list] as a serialized JSON array
 *)
function getJsonChildNameArray(list: IInterface): String;
var i: Integer;
    resultList: TStringList;
begin
    resultList := TStringList.create();

    for i := 0 to eCount(list) - 1 do begin
        resultList.add(name(eByIndex(list, i)));
    end;

    resultList.sort();
    result := stringListToJsonArray(resultList);
    resultList.free();
end;

(**
 * Returns the leveled list entries of [e] as a serialized JSON array.
 *
 * Each leveled list entry is expressed using a colon-separated triple of the referenced item, the level, and the count.
 *
 * @param e  the element to return the leveled list entries of
 * @return the entries of [e] as a serialized JSON array
 *)
function getJsonLeveledListArray(e: IInterface): String;
var i: Integer;
    entries: IInterface;
    entry: IInterface;
    entryKeys: TStringList;
    entryValues: TStringList;
    reference: String;
    level: String;
    quantity: String;
    resultList: TStringList;
begin
    resultList := TStringList.create();
    entryKeys := TStringList.create();
    entryValues := TStringList.create();

    entryKeys.add('Reference');
    entryKeys.add('Level');
    entryKeys.add('Count');

    entries := eByName(e, 'Leveled List Entries');
    for i := 0 to eCount(entries) - 1 do begin
        entry := eByName(eBySign(eByIndex(entries, i), 'LVLO'), 'Base Data');

        entryValues.clear();
        entryValues.add(evByName(entry, 'Reference'));
        entryValues.add(evByName(entry, 'Level'));
        entryValues.add(evByName(entry, 'Count'));

        resultList.add(listsToJsonObject(entryKeys, entryValues, false));
    end;

    resultList.sort();
    result := listToJsonArray(resultList);

    entryValues.free();
    entryKeys.free();
    resultList.free();
end;


end.
