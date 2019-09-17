unit ExportTabularNPC_;

uses ExportCore,
     ExportTabularCore;


var outputLines: TStringList;


function initialize: Integer;
begin
    outputLines := TStringList.create;
    outputLines.add('"File", "Form ID", "Editor ID", "Name", "Level", "Factions", "Race", "Attack race", "Class", "Keywords", "Perks", "Properties", "Aggression", "Confidence", "Assistance", "Health curve", "XP curve"');
end;

function process(npc_: IInterface): Integer;
var acbs: IInterface;
    rnam: IInterface;
    aidt: IInterface;
    cnam: IInterface;
begin
    if signature(npc_) <> 'NPC_' then begin
        addMessage('Warning: ' + name(npc_) + ' is not an NPC_. Entry was ignored.');
        exit;
    end;

    acbs := eBySignature(npc_, 'ACBS');
    rnam := linksTo(eBySignature(npc_, 'RNAM'));
    aidt := eBySignature(npc_, 'AIDT');
    cnam := linksTo(eBySignature(npc_, 'CNAM'));

    outputLines.add(
        escapeCsvString(getFileName(getFile(npc_))) + ', ' +
        escapeCsvString(stringFormID(npc_)) + ', ' +
        escapeCsvString(evBySignature(npc_, 'EDID')) + ', ' +
        escapeCsvString(evBySignature(npc_, 'FULL')) + ', ' +
        escapeCsvString(evByPath(acbs, 'Level')) + ', ' +
        escapeCsvString(getFlatFactionList(npc_)) + ', ' +
        escapeCsvString(evBySignature(npc_, 'RNAM')) + ', ' +
        escapeCsvString(evBySignature(npc_, 'ATKR')) + ', ' +
        escapeCsvString(evBySignature(npc_, 'CNAM')) + ', ' +
        escapeCsvString(getFlatKeywordList(npc_)) + ', ' +
        escapeCsvString(getFlatPerkList(npc_)) + ', ' +
        escapeCsvString(getFlatPropertyList(npc_)) + ', ' +
        escapeCsvString(evByPath(aidt, 'Aggression')) + ', ' +
        escapeCsvString(evByPath(aidt, 'Confidence')) + ', ' +
        escapeCsvString(evByPath(aidt, 'Assistance')) + ', ' +
        escapeCsvString(evBySignature(npc_, 'CVT0')) + ', ' +
        escapeCsvString(evBySignature(npc_, 'CVT2'))
    );
end;

function finalize: Integer;
begin
    createDir('dumps/');
    outputLines.saveToFile('dumps/NPC_.csv');
end;


end.
