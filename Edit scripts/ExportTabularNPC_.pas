unit ExportTabularNPC_;

uses ExportCore,
     ExportTabularCore;


var ExportTabularNPC__outputLines: TStringList;


function initialize: Integer;
begin
    ExportTabularNPC__outputLines := TStringList.create;
    ExportTabularNPC__outputLines.add('"File", "Form ID", "Editor ID", "Name", "Level", "Factions", "Race", ' +
                                      '"Attack race", "Class", "Keywords", "Perks", "Properties", "Aggression", ' +
                                      '"Confidence", "Assistance", "Health curve", "XP curve"');
end;

function canProcess(e: IInterface): Boolean;
begin
    result := signature(e) = 'NPC_';
end;

function process(npc_: IInterface): Integer;
var acbs: IInterface;
    rnam: IInterface;
    aidt: IInterface;
    cnam: IInterface;
begin
    if not canProcess(npc_) then begin
        addMessage('Warning: ' + name(npc_) + ' is not an NPC_. Entry was ignored.');
        exit;
    end;

    acbs := eBySign(npc_, 'ACBS');
    rnam := linkBySign(npc_, 'RNAM');
    aidt := eBySign(npc_, 'AIDT');
    cnam := linkBySign(npc_, 'CNAM');

    ExportTabularNPC__outputLines.add(
        escapeCsvString(getFileName(getFile(npc_))) + ', ' +
        escapeCsvString(stringFormID(npc_)) + ', ' +
        escapeCsvString(evBySign(npc_, 'EDID')) + ', ' +
        escapeCsvString(evBySign(npc_, 'FULL')) + ', ' +
        escapeCsvString(evByPath(acbs, 'Level')) + ', ' +
        escapeCsvString(getFlatFactionList(npc_)) + ', ' +
        escapeCsvString(evBySign(npc_, 'RNAM')) + ', ' +
        escapeCsvString(evBySign(npc_, 'ATKR')) + ', ' +
        escapeCsvString(evBySign(npc_, 'CNAM')) + ', ' +
        escapeCsvString(getFlatKeywordList(npc_)) + ', ' +
        escapeCsvString(getFlatPerkList(npc_)) + ', ' +
        escapeCsvString(getFlatPropertyList(npc_)) + ', ' +
        escapeCsvString(evByPath(aidt, 'Aggression')) + ', ' +
        escapeCsvString(evByPath(aidt, 'Confidence')) + ', ' +
        escapeCsvString(evByPath(aidt, 'Assistance')) + ', ' +
        escapeCsvString(evBySign(npc_, 'CVT0')) + ', ' +
        escapeCsvString(evBySign(npc_, 'CVT2'))
    );
end;

function finalize: Integer;
begin
    createDir('dumps/');
    ExportTabularNPC__outputLines.saveToFile('dumps/NPC_.csv');
end;


end.
