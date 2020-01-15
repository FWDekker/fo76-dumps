unit ExportTabularRACE;

uses ExportCore,
     ExportTabularCore;


var ExportTabularRACE_outputLines: TStringList;


function initialize: Integer;
begin
    ExportTabularRACE_outputLines := TStringList.create;
    ExportTabularRACE_outputLines.add('"File", "Form ID", "Editor ID", "Name", "Keywords", "Properties"');
end;

function canProcess(e: IInterface): Boolean;
begin
    result := signature(e) = 'RACE';
end;

function process(race: IInterface): Integer;
var acbs: IInterface;
    rnam: IInterface;
    aidt: IInterface;
    cnam: IInterface;
begin
    if not canProcess(race) then begin
        addMessage('Warning: ' + name(race) + ' is not a RACE. Entry was ignored.');
        exit;
    end;

    acbs := eBySign(race, 'ACBS');
    rnam := linkBySign(race, 'RNAM');
    aidt := eBySign(race, 'AIDT');
    cnam := linkBySign(race, 'CNAM');

    ExportTabularRACE_outputLines.add(
        escapeCsvString(getFileName(getFile(race))) + ', ' +
        escapeCsvString(stringFormID(race)) + ', ' +
        escapeCsvString(evBySign(race, 'EDID')) + ', ' +
        escapeCsvString(evBySign(race, 'FULL')) + ', ' +
        escapeCsvString(getFlatKeywordList(race)) + ', ' +
        escapeCsvString(getFlatPropertyList(race))
    );
end;

function finalize: Integer;
begin
    createDir('dumps/');
    ExportTabularRACE_outputLines.saveToFile('dumps/RACE.csv');
end;


end.
