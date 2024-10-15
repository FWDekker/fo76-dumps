unit ExportTabularRACE;

uses ExportCore,
     ExportTabularCore,
     ExportJson;


var ExportTabularRACE_outputLines: TStringList;


function initialize(): Integer;
begin
    ExportTabularRACE_outputLines := TStringList.create();
    ExportTabularRACE_outputLines.add(
        '"File", ' +       // Name of the originating ESM
        '"Form ID", ' +    // Form ID
        '"Editor ID", ' +  // Editor ID
        '"Name", ' +       // Full name
        '"Keywords", ' +   // Sorted JSON array of keywords. Each keyword is represented as
                           // `{EditorID} [KYWD:{FormID}]`
        '"Properties"'     // Sorted JSON object of properties
    );
end;

function process(el: IInterface): Integer;
begin
    if signature(el) <> 'RACE' then begin exit; end;

    _process(el);
end;

function _process(race: IInterface): Integer;
var acbs: IInterface;
    rnam: IInterface;
    aidt: IInterface;
    cnam: IInterface;
begin
    acbs := elementBySignature(race, 'ACBS');
    rnam := linksTo(elementBySignature(race, 'RNAM'));
    aidt := elementBySignature(race, 'AIDT');
    cnam := linksTo(elementBySignature(race, 'CNAM'));

    ExportTabularRACE_outputLines.add(
        escapeCsvString(getFileName(getFile(race))) + ', ' +
        escapeCsvString(stringFormID(race)) + ', ' +
        escapeCsvString(getEditValue(elementBySignature(race, 'EDID'))) + ', ' +
        escapeCsvString(getEditValue(elementBySignature(race, 'FULL'))) + ', ' +
        escapeCsvString(getJsonChildArray(elementByPath(race, 'Keywords\KWDA'))) + ', ' +
        escapeCsvString(getJsonPropertyObject(race))
    );
end;

function finalize(): Integer;
begin
    createDir('dumps/');
    ExportTabularRACE_outputLines.saveToFile('dumps/RACE.csv');
    ExportTabularRACE_outputLines.free();
end;


end.
