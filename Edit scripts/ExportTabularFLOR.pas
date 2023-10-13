unit ExportTabularFLOR;

uses ExportCore,
     ExportTabularCore,
     ExportJson,
     ExportTabularLOC;


var ExportTabularFLOR_outputLines: TStringList;
var ExportTabularFLOR_LOC_outputLines: TStringList;


function initialize(): Integer;
begin
    ExportTabularFLOR_outputLines := TStringList.create();
    ExportTabularFLOR_outputLines.add(
            '"File"'        // Name of the originating ESM
        + ', "Form ID"'     // Form ID
        + ', "Editor ID"'   // Editor ID
        + ', "Name"'        // Full name
        + ', "Ingredient"'  // Item obtained when harvested
        + ', "Keywords"'    // Sorted JSON array of keywords. Each keyword is represented as
                            // `{EditorID} [KYWD:{FormID}]`
        + ', "Properties"'  // Sorted JSON object of properties
    );

    ExportTabularFLOR_LOC_outputLines := initLocList();
end;

function canProcess(el: IInterface): Boolean;
begin
    result := signature(el) = 'FLOR';
end;

function process(flor: IInterface): Integer;
var data: IInterface;
begin
    if not canProcess(flor) then begin
        addWarning(name(flor) + ' is not a FLOR. Entry was ignored.');
        exit;
    end;

    data := eBySign(flor, 'DATA');

    ExportTabularFLOR_outputLines.add(
          escapeCsvString(getFileName(getFile(flor))) + ', '
        + escapeCsvString(stringFormID(flor)) + ', '
        + escapeCsvString(evBySign(flor, 'EDID')) + ', '
        + escapeCsvString(evBySign(flor, 'FULL')) + ', '
        + escapeCsvString(evByName(flor, 'PFIG')) + ', '
        + escapeCsvString(getJsonChildArray(eByPath(flor, 'Keywords\KWDA'))) + ', '
        + escapeCsvString(getJsonPropertyObject(flor))
    );

    appendLocationData(ExportTabularFLOR_LOC_outputLines, flor);
end;

function finalize(): Integer;
begin
    createDir('dumps/');

    ExportTabularFLOR_outputLines.saveToFile('dumps/FLOR.csv');
    ExportTabularFLOR_outputLines.free();

    ExportTabularFLOR_LOC_outputLines.saveToFile('dumps/FLOR_LOC.csv');
    ExportTabularFLOR_LOC_outputLines.free();
end;


end.
