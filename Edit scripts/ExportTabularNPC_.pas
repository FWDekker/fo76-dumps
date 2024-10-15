unit ExportTabularNPC_;

uses ExportCore,
     ExportTabularCore,
     ExportJson;


var ExportTabularNPC__outputLines: TStringList;


function initialize(): Integer;
begin
    ExportTabularNPC__outputLines := TStringList.create();
    ExportTabularNPC__outputLines.add(
        '"File", ' +            // Name of the originating ESM
        '"Form ID", ' +         // Form ID
        '"Editor ID", ' +       // Editor ID
        '"Name", ' +            // Full name
        '"Name (short)", ' +    // Short name
        '"Level", ' +           // Level
        '"Factions", ' +        // Sorted JSON array of factions. Each faction is represented by its editor ID
        '"Race", ' +            // Race, formatted as `<editor id> "<full name>" [<signature>:<form id>]`
        '"Attack race", ' +     // Attack race, formatted as `<editor id> "<full name>" [<signature>:<form id>]`
        '"Class", ' +           // Class, formatted as `<editor id> "<full name>" [<signature>:<form id>]`
        '"Keywords", ' +        // Sorted JSON array of keywords. Each keyword is represented as
                                // `{EditorID} [KYWD:{FormID}]`
        '"Perks", ' +           // Sorted JSON array of perks. Each perk is formatted as `<editor id>=[value]`
        '"Properties", ' +      // Sorted JSON object of properties
        '"Aggression", ' +      // AI aggression level as a string
        '"Confidence", ' +      // AI confidence level as a string
        '"Assistance", ' +      // AI assistance level as a string
        '"Health curve", ' +    // Health curve, formatted as `<editor id> [<signature>:<form id>]`
        '"XP curve", ' +        // XP curve, formatted as `<editor id> [<signature>:<form id>]`
        '"Default outfit", ' +  // Default outfit
        '"Voice type", ' +      // Voice type, formatted as `<editor id> "<full name>" [<signature>:<form id>]`
        '"Hair color", ' +      // Hair color, formatted as `<editor id> "<full name>" [<signature>:<form id>]`
        '"Head parts"'          // Sorted JSON array of head parts. Each part is formatted as
                                // `<editor id> "<full name>" [<signature>:<form id>]`
    );
end;

function process(el: IInterface): Integer;
begin
    if signature(el) <> 'NPC_' then begin exit; end;

    _process(el);
end;

function _process(npc_: IInterface): Integer;
var acbs: IInterface;
    rnam: IInterface;
    aidt: IInterface;
    cnam: IInterface;
begin
    acbs := elementBySignature(npc_, 'ACBS');
    rnam := linksTo(elementBySignature(npc_, 'RNAM'));
    aidt := elementBySignature(npc_, 'AIDT');
    cnam := linksTo(elementBySignature(npc_, 'CNAM'));

    ExportTabularNPC__outputLines.add(
        escapeCsvString(getFileName(getFile(npc_))) + ', ' +
        escapeCsvString(stringFormID(npc_)) + ', ' +
        escapeCsvString(getEditValue(elementBySignature(npc_, 'EDID'))) + ', ' +
        escapeCsvString(getEditValue(elementBySignature(npc_, 'FULL'))) + ', ' +
        escapeCsvString(getEditValue(elementBySignature(npc_, 'SHRT'))) + ', ' +
        escapeCsvString(getEditValue(elementByName(acbs, 'Level'))) + ', ' +
        escapeCsvString(getJsonFactionArray(npc_)) + ', ' +
        escapeCsvString(getEditValue(elementBySignature(npc_, 'RNAM'))) + ', ' +
        escapeCsvString(getEditValue(elementBySignature(npc_, 'ATKR'))) + ', ' +
        escapeCsvString(getEditValue(elementBySignature(npc_, 'CNAM'))) + ', ' +
        escapeCsvString(getJsonChildArray(elementByPath(npc_, 'Keywords\KWDA'))) + ', ' +
        escapeCsvString(getJsonPerkArray(npc_)) + ', ' +
        escapeCsvString(getJsonPropertyObject(npc_)) + ', ' +
        escapeCsvString(getEditValue(elementByName(aidt, 'Aggression'))) + ', ' +
        escapeCsvString(getEditValue(elementByName(aidt, 'Confidence'))) + ', ' +
        escapeCsvString(getEditValue(elementByName(aidt, 'Assistance'))) + ', ' +
        escapeCsvString(getEditValue(elementBySignature(npc_, 'CVT0'))) + ', ' +
        escapeCsvString(getEditValue(elementBySignature(npc_, 'CVT2'))) + ', ' +
        escapeCsvString(getEditValue(elementBySignature(npc_, 'DOFT'))) + ', ' +
        escapeCsvString(getEditValue(elementBySignature(npc_, 'VTCK'))) + ', ' +
        escapeCsvString(getEditValue(elementBySignature(npc_, 'HCLF'))) + ', ' +
        escapeCsvString(getJsonChildArray(elementByName(npc_, 'Head Parts')))
    );
end;

function finalize(): Integer;
begin
    createDir('dumps/');
    ExportTabularNPC__outputLines.saveToFile('dumps/NPC_.csv');
    ExportTabularNPC__outputLines.free();
end;


(**
 * Returns a JSON array of each of the NPC's factions, each faction as a JSON object.
 *
 * @param npc_  the NPC to return the factions of
 * @return a JSON array of each of the NPC's factions, each faction as a JSON object
 *)
function getJsonFactionArray(npc_: IInterface): String;
var i: Integer;
    factions: IInterface;
    faction: IInterface;
    resultList: TStringList;
begin
    resultList := TStringList.create();

    factions := elementByName(npc_, 'Factions');
    for i := 0 to elementCount(factions) - 1 do begin
        faction := elementByIndex(factions, i);
        resultList.add(
            '{' +
            '"Faction":"' + escapeJson(getEditValue(elementByName(faction, 'Faction'))) + '",' +
            '"Rank":"' + escapeJson(getEditValue(elementByName(faction, 'Rank'))) + '"' +
            '}'
        );
    end;

    resultList.sort();
    result := listToJsonArray(resultList);
    resultList.free();
end;

(**
 * Returns a JSON array of references to the NPC's perks.
 *
 * @param npc_  the NPC to return the perks of
 * @return a JSON array of references to the NPC's perks
 *)
function getJsonPerkArray(npc_: IInterface): String;
var i: Integer;
    perks: IInterface;
    perk: IInterface;
    resultList: TStringList;
begin
    resultList := TStringList.create();

    perks := elementByName(npc_, 'Perks');
    for i := 0 to elementCount(perks) - 1 do begin
        perk := elementByIndex(perks, i);
        resultList.add(getEditValue(elementByName(perk, 'Perk')));
    end;

    resultList.sort();
    result := stringListToJsonArray(resultList);
    resultList.free();
end;


end.
