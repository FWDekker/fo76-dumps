unit ExportTabularFLOR;

uses ExportCore,
     ExportTabularCore,
     ExportJson;


var ExportTabularFLOR_outputLines: TStringList;
var ExportTabularLOC_outputLines: TStringList;


function initialize(): Integer;
begin
    ExportTabularFLOR_outputLines := TStringList.create();
    ExportTabularFLOR_outputLines.add(
            '"File"'        // Name of the originating ESM
        + ', "Form ID"'     // Form ID
        + ', "Editor ID"'   // Editor ID
        + ', "Name"'        // Full name
        + ', "Ingredient"'  // Item obtained when harvested
        + ', "Keywords"'    // Sorted JSON array of keywords. Each keyword is represented by its editor ID
        + ', "Properties"'  // Sorted JSON object of properties
    );

    ExportTabularLOC_outputLines := initializeLocationTabular();
end;

function canProcess(e: IInterface): Boolean;
begin
    result := signature(e) = 'FLOR';
end;

function process(flora: IInterface): Integer;
var data: IInterface;
begin
    if not canProcess(flora) then begin
        addWarning(name(flora) + ' is not a FLOR. Entry was ignored.');
        exit;
    end;

    data := eBySign(flora, 'DATA');

    ExportTabularFLOR_outputLines.add(
          escapeCsvString(getFileName(getFile(flora))) + ', '
        + escapeCsvString(stringFormID(flora)) + ', '
        + escapeCsvString(evBySign(flora, 'EDID')) + ', '
        + escapeCsvString(evBySign(flora, 'FULL')) + ', '
        + escapeCsvString(evByName(flora, 'PFIG')) + ', '
        + escapeCsvString(getJsonKeywordArray(flora)) + ', '
        + escapeCsvString(getJsonPropertyObject(flora))
    );

    ExportTabularLOC_outputLines.addStrings(getLocationData(flora));
end;

function finalize(): Integer;
begin
    createDir('dumps/');
    ExportTabularFLOR_outputLines.saveToFile('dumps/FLOR.csv');
    ExportTabularLOC_outputLines.saveToFile('dumps/FLOR_LOC.csv');
    ExportTabularLOC_outputLines.free();
    ExportTabularFLOR_outputLines.free();
end;


end.
