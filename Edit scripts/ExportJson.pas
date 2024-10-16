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
 * Escapes a selection of special JSON characters in [text].
 *
 * @param text  the text to escape
 * @return a (partially) JSON-escaped version of [text]
 *)
function escapeJson(text: string): string;
begin
    result := text;
    result := stringReplace(result, '\', '\\', [rfReplaceAll]);
    result := stringReplace(result, '"', '\"', [rfReplaceAll]);
    result := stringReplace(result, #13 + #10, '\n', [rfReplaceAll]);
    result := stringReplace(result, #10, '\n', [rfReplaceAll]);
end;

(**
 * Serializes the list of values into a JSON array.
 *
 * Each list entry is interpreted as a raw value and is not surrounded with quotes or escaped.
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
        list[i] := '"' + escapeJson(list[i]) + '"';
    end;
    result := listToJsonArray(list);
end;



(***
 *
 * Domain-specific serialization functions.
 *
 **)

(**
 * Returns the properties of [el] as a serialized JSON object.
 *
 * Each property is expressed using the property's editor ID as the key and either the property's value or the
 * property's curve table's editor ID as the value.
 *
 * @param el  the element to return the properties of
 * @return the properties of [el] as a serialized JSON object
 *)
function getJsonPropertyObject(el: IInterface): String;
var i: Integer;
    props: IInterface;
    prop: IInterface;
    avEdid: String;
    avValue: String;
begin
    result := '';

    props := elementBySignature(el, 'PRPS');
    for i := 0 to elementCount(props) - 1 do begin
        prop := elementByIndex(props, i);
        avEdid := getEditValue(elementBySignature(linksTo(elementByName(prop, 'Actor Value')), 'EDID'));

        if assigned(linksTo(elementByName(prop, 'Curve Table'))) then begin
            avValue := getEditValue(elementBySignature(linksTo(elementByName(prop, 'Curve Table')), 'EDID'));
        end else begin
            avValue := getEditValue(elementByName(prop, 'Value'));
        end;
        try
            avValue := floatToStr(strToFloat(avValue));  // Remove unnecessary decimals
        except end;

        result := result + '"' + escapeJson(avEdid) + '":"' + escapeJson(avValue) + '"';
        if i < elementCount(props) - 1 then begin
            result := result + ',';
        end;
    end;

    result := '{' + result + '}';
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

    for i := 0 to elementCount(list) - 1 do begin
        resultList.add(getEditValue(elementByIndex(list, i)));
    end;

    resultList.sort();
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

    for i := 0 to elementCount(list) - 1 do begin
        resultList.add(name(elementByIndex(list, i)));
    end;

    resultList.sort();
    result := stringListToJsonArray(resultList);
    resultList.free();
end;


end.
