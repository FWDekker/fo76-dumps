unit ExportTabularRACE;

uses ExportCore,
     ExportTabularCore,
     ExportJson;


var ExportTabularRACE_outputLines: TStringList;


function initialize(): Integer;
begin
    ExportTabularRACE_outputLines := TStringList.create();
    ExportTabularRACE_outputLines.add(
            '"File"'        // Name of the originating ESM
        + ', "Form ID"'     // Form ID
        + ', "Editor ID"'   // Editor ID
        + ', "Name"'        // Full name
        + ', "Keywords"'    // Sorted JSON array of keywords. Each keyword is represented by its editor ID
        + ', "Properties"'  // Sorted JSON object of properties
    );
end;

function canProcess(el: IInterface): Boolean;
begin
    result := signature(el) = 'RACE';
end;

function process(race: IInterface): Integer;
var acbs: IInterface;
    rnam: IInterface;
    aidt: IInterface;
    cnam: IInterface;
begin
    if not canProcess(race) then begin
        addWarning(name(race) + ' is not a RACE. Entry was ignored.');
        exit;
    end;

    acbs := eBySign(race, 'ACBS');
    rnam := linkBySign(race, 'RNAM');
    aidt := eBySign(race, 'AIDT');
    cnam := linkBySign(race, 'CNAM');

    ExportTabularRACE_outputLines.add(
          escapeCsvString(getFileName(getFile(race))) + ', '
        + escapeCsvString(stringFormID(race)) + ', '
        + escapeCsvString(evBySign(race, 'EDID')) + ', '
        + escapeCsvString(evBySign(race, 'FULL')) + ', '
        + escapeCsvString(getJsonChildArray(eBySign(eByPath(race, 'Keywords'), 'KWDA'))) + ', '
        + escapeCsvString(getJsonPropertyObject(race))
    );
end;

function finalize(): Integer;
begin
    createDir('dumps/');
    ExportTabularRACE_outputLines.saveToFile('dumps/RACE.csv');
    ExportTabularRACE_outputLines.free();
end;


end.
