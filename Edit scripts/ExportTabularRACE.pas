unit ExportTabularRACE;

uses ExportCore,
     ExportTabularCore;


var outputLines: TStringList;


function initialize: Integer;
begin
    outputLines := TStringList.create;
    outputLines.add('"File", "Form ID", "Editor ID", "Name", "Keywords", "Properties"');
end;

function process(race: IInterface): Integer;
var acbs: IInterface;
    rnam: IInterface;
    aidt: IInterface;
    cnam: IInterface;
begin
    if signature(race) <> 'RACE' then begin
        addMessage('Warning: ' + name(race) + ' is not a RACE. Entry was ignored.');
        exit;
    end;

    acbs := eBySignature(race, 'ACBS');
    rnam := linksTo(eBySignature(race, 'RNAM'));
    aidt := eBySignature(race, 'AIDT');
    cnam := linksTo(eBySignature(race, 'CNAM'));

    outputLines.add(
        escapeCsvString(getFileName(getFile(race))) + ', ' +
        escapeCsvString(stringFormID(race)) + ', ' +
        escapeCsvString(evBySignature(race, 'EDID')) + ', ' +
        escapeCsvString(evBySignature(race, 'FULL')) + ', ' +
        escapeCsvString(getFlatKeywordList(race)) + ', ' +
        escapeCsvString(getFlatPropertyList(race))
    );
end;

function finalize: Integer;
begin
    createDir('dumps/');
    outputLines.saveToFile('dumps/RACE.csv');
end;


end.
