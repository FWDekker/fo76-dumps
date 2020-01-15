(**
 * A collection of functions used when creating tabular dumps.
 *)
unit ExportTabularCore;


(**
 * Escapes [text] by escaping quotes and then surrounding it with quotes.
 *
 * @param the text to escape
 * @return a CSV-escaped version of [text]
 *)
function escapeCsvString(text: String): String;
begin
    result := text;
    result := stringReplace(result, '"', '\"', [rfReplaceAll]);
    result := '"' + text + '"';
end;


(**
 * Returns the keywords of [e] as a comma-separated list of editor IDs.
 *
 * @param e the element to return the keywords of
 * @return the keywords of [e] as a comma-separated list of editor IDs
 *)
function getFlatKeywordList(e: IInterface): String;
var i: Integer;
    keywords: IInterface;
begin
    result := ',';

    keywords := eBySign(eByPath(e, 'Keywords'), 'KWDA');
    for i := 0 to eCount(keywords) - 1 do begin
        result := result + evBySign(linkByIndex(keywords, i), 'EDID') + ',';
    end;
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
begin
    result := ',';

    factions := eByPath(e, 'Factions');
    for i := 0 to eCount(factions) - 1 do begin
        faction := eByIndex(factions, i);
        result := result + evBySign(linkByPath(faction, 'Faction'), 'EDID') + ',';
    end;
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
begin
    result := ',';

    perks := eByPath(e, 'Perks');
    for i := 0 to eCount(perks) - 1 do begin
        perk := eByIndex(perks, i);
        result := result + evBySign(linkByPath(perk, 'Perk'), 'EDID') + '=' + evByPath(perk, 'Rank') + ',';
    end;
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
begin
    result := ',';

    props := eBySign(e, 'PRPS');
    for i := 0 to eCount(props) - 1 do begin
        prop := eByIndex(props, i);
        avEdid := evBySign(linkByPath(prop, 'Actor Value'), 'EDID');

        if assigned(linkByPath(prop, 'Curve Table')) then begin
            result := result + avEdid + '=' + evBySign(linkByPath(prop, 'Curve Table'), 'EDID') + ',';
        end else begin
            result := result + avEdid + '=' + evByPath(prop, 'Value') + ',';
        end;
    end;
end;


end.
