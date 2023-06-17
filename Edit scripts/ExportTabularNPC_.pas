unit ExportTabularNPC_;

uses ExportCore,
     ExportTabularCore,
     ExportJson;


var ExportTabularNPC__outputLines: TStringList;


function initialize(): Integer;
begin
    ExportTabularNPC__outputLines := TStringList.create();
    ExportTabularNPC__outputLines.add(
            '"File"'            // Name of the originating ESM
        + ', "Form ID"'         // Form ID
        + ', "Editor ID"'       // Editor ID
        + ', "Name"'            // Full name
        + ', "Name (short)"'    // Short name
        + ', "Level"'           // Level
        + ', "Factions"'        // Sorted JSON array of factions. Each faction is represented by its editor ID
        + ', "Race"'            // Race, formatted as `<editor id> "<full name>" [<signature>:<form id>]`
        + ', "Attack race"'     // Attack race, formatted as `<editor id> "<full name>" [<signature>:<form id>]`
        + ', "Class"'           // Class, formatted as `<editor id> "<full name>" [<signature>:<form id>]`
        + ', "Keywords"'        // Sorted JSON array of keywords. Each keyword is represented as
                                // `{EditorID} [KYWD:{FormID}]`
        + ', "Perks"'           // Sorted JSON array of perks. Each perk is formatted as `<editor id>=[value]`
        + ', "Properties"'      // Sorted JSON object of properties
        + ', "Aggression"'      // AI aggression level as a string
        + ', "Confidence"'      // AI confidence level as a string
        + ', "Assistance"'      // AI assistance level as a string
        + ', "Health curve"'    // Health curve, formatted as `<editor id> [<signature>:<form id>]`
        + ', "XP curve"'        // XP curve, formatted as `<editor id> [<signature>:<form id>]`
        + ', "Default outfit"'  // Default outfit
        + ', "Voice type"'      // Voice type, formatted as `<editor id> "<full name>" [<signature>:<form id>]`
        + ', "Hair color"'      // Hair color, formatted as `<editor id> "<full name>" [<signature>:<form id>]`
        + ', "Head parts"'      // Sorted JSON array of head parts. Each part is formatted as
                                // `<editor id> "<full name>" [<signature>:<form id>]`
    );
end;

function canProcess(el: IInterface): Boolean;
begin
    result := signature(el) = 'NPC_';
end;

function process(npc_: IInterface): Integer;
var acbs: IInterface;
    rnam: IInterface;
    aidt: IInterface;
    cnam: IInterface;
begin
    if not canProcess(npc_) then begin
        addWarning(name(npc_) + ' is not an NPC_. Entry was ignored.');
        exit;
    end;

    acbs := eBySign(npc_, 'ACBS');
    rnam := linkBySign(npc_, 'RNAM');
    aidt := eBySign(npc_, 'AIDT');
    cnam := linkBySign(npc_, 'CNAM');

    ExportTabularNPC__outputLines.add(
          escapeCsvString(getFileName(getFile(npc_))) + ', '
        + escapeCsvString(stringFormID(npc_)) + ', '
        + escapeCsvString(evBySign(npc_, 'EDID')) + ', '
        + escapeCsvString(evBySign(npc_, 'FULL')) + ', '
        + escapeCsvString(evBySign(npc_, 'SHRT')) + ', '
        + escapeCsvString(evByPath(acbs, 'Level')) + ', '
        + escapeCsvString(getJsonFactionArray(npc_)) + ', '
        + escapeCsvString(evBySign(npc_, 'RNAM')) + ', '
        + escapeCsvString(evBySign(npc_, 'ATKR')) + ', '
        + escapeCsvString(evBySign(npc_, 'CNAM')) + ', '
        + escapeCsvString(getJsonChildArray(eBySign(eByPath(npc_, 'Keywords'), 'KWDA'))) + ', '
        + escapeCsvString(getJsonPerkArray(npc_)) + ', '
        + escapeCsvString(getJsonPropertyObject(npc_)) + ', '
        + escapeCsvString(evByPath(aidt, 'Aggression')) + ', '
        + escapeCsvString(evByPath(aidt, 'Confidence')) + ', '
        + escapeCsvString(evByPath(aidt, 'Assistance')) + ', '
        + escapeCsvString(evBySign(npc_, 'CVT0')) + ', '
        + escapeCsvString(evBySign(npc_, 'CVT2')) + ', '
        + escapeCsvString(evBySign(npc_, 'DOFT')) + ', '
        + escapeCsvString(evBySign(npc_, 'VTCK')) + ', '
        + escapeCsvString(evBySign(npc_, 'HCLF')) + ', '
        + escapeCsvString(getJsonChildArray(eByPath(npc_, 'Head Parts')))
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

    factions := eByName(npc_, 'Factions');
    for i := 0 to eCount(factions) - 1 do begin
        faction := eByIndex(factions, i);
        resultList.add(
            '{' +
             '"Faction":"' + escapeJson(evByName(faction, 'Faction')) + '"' +
            ',"Rank":"'    + escapeJson(evByName(faction, 'Rank'))    + '"' +
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

    perks := eByName(npc_, 'Perks');
    for i := 0 to eCount(perks) - 1 do begin
        perk := eByIndex(perks, i);
        resultList.add(evByName(perk, 'Perk'));
    end;

    resultList.sort();
    result := stringListToJsonArray(resultList);
    resultList.free();
end;


end.
