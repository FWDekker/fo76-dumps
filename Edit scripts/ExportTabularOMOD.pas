unit ExportTabularOMOD;

uses ExportCore,
     ExportTabularCore,
     ExportJson;


var ExportTabularOMOD_outputLines: TStringList;


function initialize(): Integer;
begin
    ExportTabularOMOD_outputLines := TStringList.create();
    ExportTabularOMOD_outputLines.add(
            '"File"'                 // Name of the originating ESM
        + ', "Form ID"'              // Form ID
        + ', "Editor ID"'            // Editor ID
        + ', "Name"'                 // Full name
        + ', "Description"'          // Description
        + ', "Form type"'            // Type of mod (`Armor` or `Weapon`)
        + ', "Loose mod"'            // Loose mod (MISC)
        + ', "Attach point"'         // Attach point
        + ', "Attach parent slots"'  // Sorted JSON array of attach parent slots
        + ', "Includes"'             // Sorted JSON object of includes
        + ', "Properties"'           // Sorted JSON object of properties
        + ', "Target keywords"'      // Sorted JSON array of keywords. Each keyword is represented as
                                     // `{EditorID} [KYWD:{FormID}]`
    );
end;

function canProcess(el: IInterface): Boolean;
begin
    result := signature(el) = 'OMOD';
end;

function process(omod: IInterface): Integer;
var data: IInterface;
begin
    if not canProcess(omod) then begin
        addWarning(name(omod) + ' is not a OMOD. Entry was ignored.');
        exit;
    end;

    data := eBySign(omod, 'DATA');

    ExportTabularOMOD_outputLines.add(
              escapeCsvString(getFileName(getFile(omod))) + ', '
            + escapeCsvString(stringFormID(omod)) + ', '
            + escapeCsvString(evBySign(omod, 'EDID')) + ', '
            + escapeCsvString(evBySign(omod, 'FULL')) + ', '
            + escapeCsvString(evBySign(omod, 'DESC')) + ', '
            + escapeCsvString(evByName(data, 'Form Type')) + ', '
            + escapeCsvString(evBySign(omod, 'LNAM')) + ', '
            + escapeCsvString(evByName(data, 'Attach Point')) + ', '
            + escapeCsvString(getJsonChildArray(eByName(data, 'Attach Parent Slots'))) + ', '
            + escapeCsvString(getJsonIncludesArray(data)) + ', '
            + escapeCsvString(getJsonOMODPropertyObject(data)) + ', '
            + escapeCsvString(getJsonChildArray(eBySign(omod, 'MNAM')))
        );
end;

function finalize(): Integer;
begin
    createDir('dumps/');
    ExportTabularOMOD_outputLines.saveToFile('dumps/OMOD.csv');
    ExportTabularOMOD_outputLines.free();
end;


(**
 * Returns a JSON array of the mods that are included by the given mod.
 *
 * @param data  the mod's data
 * @return a JSON array of the mods that are included by the given mod
 *)
function getJsonIncludesArray(data: IInterface): String;
var i: Integer;
    includes: IInterface;
    include: IInterface;
    resultList: TStringList;
begin
    resultList := TStringList.create();

    includes := eByName(data, 'Includes');
    for i := 0 to eCount(includes) - 1 do begin
        include := eByIndex(includes, i);
        resultList.add(
            '{' +
             '"Mod":"'            + escapeJson(evByName(include, 'Mod'))            + '"' +
            ',"Minimum Level":"'  + escapeJson(evByName(include, 'Minimum Level'))  + '"' +
            ',"Optional":"'       + escapeJson(evByName(include, 'Optional'))       + '"' +
            ',"Don''t Use All":"' + escapeJson(evByName(include, 'Don''t Use All')) + '"' +
            '}'
        );
    end;

    resultList.sort();
    result := listToJsonArray(resultList);
    resultList.free();
end;

(**
 * Returns a JSON array of the properties of the given mod.
 *
 * @param data  the mod's data
 * @return a JSON array of the properties of the given mod
 *)
function getJsonOMODPropertyObject(data: IInterface): String;
var i: Integer;
    props: IInterface;
    prop: IInterface;
    resultList: TStringList;
begin
    resultList := TStringList.create();

    props := eByName(data, 'Properties');
    for i := 0 to eCount(props) - 1 do begin
        prop := eByIndex(props, i);
        resultList.add(
            '{' +
             '"Value Type":"'    + escapeJson(evByName(prop, 'Value Type'))    + '"' +
            ',"Function Type":"' + escapeJson(evByName(prop, 'Function Type')) + '"' +
            ',"Property":"'      + escapeJson(evByName(prop, 'Property'))      + '"' +
            ',"Value 1":"'       + escapeJson(evByName(prop, 'Value 1'))       + '"' +
            ',"Value 2":"'       + escapeJson(evByName(prop, 'Value 2'))       + '"' +
            ',"Curve Table":"'   + escapeJson(evByName(prop, 'Curve Table'))   + '"' +
            '}'
        );
    end;

    resultList.sort();
    result := listToJsonArray(resultList);
    resultList.free();
end;


end.
