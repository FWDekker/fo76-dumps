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
        '"File", ' +                  // Name of the originating ESM
        '"Form ID", ' +               // Form ID
        '"Editor ID", ' +             // Editor ID
        '"Name", ' +                  // Full name
        '"Weight", ' +                // Item weight in pounds
        '"Value", ' +                 // Item value in bottlecaps
        '"Health", ' +                // Item health in points
        '"Race", ' +                  // Race that can wear this armor
        '"Levels", ' +                // Sorted JSON array of possible armor levels
        '"DR curve", ' +              // Damage Resistance curve
        '"Durability min curve", ' +  // Min durability curve
        '"Durability max curve", ' +  // Max durability curve
        '"Condition dmg curve", ' +   // Condition damage scale factor curve
        '"Attach slots", ' +          // Sorted JSON array of attachment slots available to the armor
        '"Equip slots", ' +           // Sorted JSON array of equipment slots used by the armor
        '"Keywords"'                  // Sorted JSON array of keywords. Each keyword is represented as
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
    data := elementBySignature(armo, 'DATA');

    ExportTabularARMO_outputLines.add(
        escapeCsvString(getFileName(getFile(armo))) + ', ' +
        escapeCsvString(stringFormID(armo)) + ', ' +
        escapeCsvString(getEditValue(elementBySignature(armo, 'EDID'))) + ', ' +
        escapeCsvString(getEditValue(elementBySignature(armo, 'FULL'))) + ', ' +
        escapeCsvString(getEditValue(elementByName(data, 'Weight'))) + ', ' +
        escapeCsvString(getEditValue(elementByName(data, 'Value'))) + ', ' +
        escapeCsvString(getEditValue(elementByName(data, 'Health'))) + ', ' +
        escapeCsvString(getEditValue(elementBySignature(armo, 'RNAM'))) + ', ' +
        escapeCsvString(getJsonChildArray(elementBySignature(armo, 'EILV'))) + ',' +
        escapeCsvString(getEditValue(elementBySignature(armo, 'CVT0'))) + ',' +
        escapeCsvString(getEditValue(elementBySignature(armo, 'CVT1'))) + ',' +
        escapeCsvString(getEditValue(elementBySignature(armo, 'CVT3'))) + ',' +
        escapeCsvString(getEditValue(elementBySignature(armo, 'CVT2'))) + ',' +
        escapeCsvString(getJsonChildArray(elementBySignature(armo, 'APPR'))) + ',' +
        escapeCsvString(getJsonChildNameArray(elementByIndex(elementBySignature(armo, 'BOD2'), 0))) + ', ' +
        escapeCsvString(getJsonChildArray(elementByPath(armo, 'Keywords\KWDA')))
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
