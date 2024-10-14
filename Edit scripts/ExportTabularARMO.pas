unit ExportTabularARMO;

uses ExportCore,
     ExportTabularCore,
     ExportJson,
     ExportTabularLOC;


var ExportTabularARMO_outputLines: TStringList;
var ExportTabularARMO_LOC_outputLines: TStringList;


function initialize(): Integer;
begin
    ExportTabularARMO_outputLines := TStringList.create();
    ExportTabularARMO_outputLines.add(
            '"File"'                  // Name of the originating ESM
        + ', "Form ID"'               // Form ID
        + ', "Editor ID"'             // Editor ID
        + ', "Name"'                  // Full name
        + ', "Weight"'                // Item weight in pounds
        + ', "Value"'                 // Item value in bottlecaps
        + ', "Health"'                // Item health in points
        + ', "Race"'                  // Race that can wear this armor
        + ', "Levels"'                // Sorted JSON array of possible armor levels
        + ', "DR curve"'              // Damage Resistance curve
        + ', "Durability min curve"'  // Min durability curve
        + ', "Durability max curve"'  // Max durability curve
        + ', "Condition dmg curve"'   // Condition damage scale factor curve
        + ', "Attach slots"'          // Sorted JSON array of attachment slots available to the armor
        + ', "Equip slots"'           // Sorted JSON array of equipment slots used by the armor
        + ', "Keywords"'              // Sorted JSON array of keywords. Each keyword is represented as
                                      // `{EditorID} [KYWD:{FormID}]`
    );

    ExportTabularARMO_LOC_outputLines := initLocList();
end;

function process(el: IInterface): Integer;
begin
    if signature(el) <> 'ARMO' then begin exit; end;

    _process(el);
end;

function _process(armo: IInterface): Integer;
var data: IInterface;
begin
    data := eBySign(armo, 'DATA');

    ExportTabularARMO_outputLines.add(
          escapeCsvString(getFileName(getFile(armo))) + ', '
        + escapeCsvString(stringFormID(armo)) + ', '
        + escapeCsvString(evBySign(armo, 'EDID')) + ', '
        + escapeCsvString(evBySign(armo, 'FULL')) + ', '
        + escapeCsvString(evByName(data, 'Weight')) + ', '
        + escapeCsvString(evByName(data, 'Value')) + ', '
        + escapeCsvString(evByName(data, 'Health')) + ', '
        + escapeCsvString(evBySign(armo, 'RNAM')) + ', '
        + escapeCsvString(getJsonChildArray(eBySign(armo, 'EILV'))) + ','
        + escapeCsvString(evBySign(armo, 'CVT0')) + ','
        + escapeCsvString(evBySign(armo, 'CVT1')) + ','
        + escapeCsvString(evBySign(armo, 'CVT3')) + ','
        + escapeCsvString(evBySign(armo, 'CVT2')) + ','
        + escapeCsvString(getJsonChildArray(eBySign(armo, 'APPR'))) + ','
        + escapeCsvString(getJsonChildNameArray(eByIndex(eBySign(armo, 'BOD2'), 0))) + ', '
        + escapeCsvString(getJsonChildArray(eByPath(armo, 'Keywords\KWDA')))
    );

    appendLocationData(ExportTabularARMO_LOC_outputLines, armo);
end;

function finalize(): Integer;
begin
    createDir('dumps/');

    ExportTabularARMO_outputLines.saveToFile('dumps/ARMO.csv');
    ExportTabularARMO_outputLines.free();

    ExportTabularARMO_LOC_outputLines.saveToFile('dumps/ARMO_LOC.csv');
    ExportTabularARMO_LOC_outputLines.free();
end;


end.
