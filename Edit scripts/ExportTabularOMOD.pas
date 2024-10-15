unit ExportTabularOMOD;

uses ExportCore,
     ExportTabularCore,
     ExportJson;


var ExportTabularOMOD_outputLines: TStringList;


function initialize(): Integer;
begin
    ExportTabularOMOD_outputLines := TStringList.create();
    ExportTabularOMOD_outputLines.add(
        '"File", ' +                 // Name of the originating ESM
        '"Form ID", ' +              // Form ID
        '"Editor ID", ' +            // Editor ID
        '"Name", ' +                 // Full name
        '"Description", ' +          // Description
        '"Form type", ' +            // Type of mod (`Armor` or `Weapon`)
        '"Loose mod", ' +            // Loose mod (MISC)
        '"Attach point", ' +         // Attach point
        '"Attach parent slots", ' +  // Sorted JSON array of attach parent slots
        '"Includes", ' +             // Sorted JSON object of includes
        '"Properties", ' +           // Sorted JSON object of properties
        '"Target keywords"'          // Sorted JSON array of keywords. Each keyword is represented as
                                     // `{EditorID} [KYWD:{FormID}]`
    );
end;

function process(el: IInterface): Integer;
begin
    if signature(el) <> 'OMOD' then begin exit; end;

    _process(el);
end;

function _process(omod: IInterface): Integer;
var data: IInterface;
begin
    data := elementBySignature(omod, 'DATA');

    ExportTabularOMOD_outputLines.add(
        escapeCsvString(getFileName(getFile(omod))) + ', ' +
        escapeCsvString(stringFormID(omod)) + ', ' +
        escapeCsvString(getEditValue(elementBySignature(omod, 'EDID'))) + ', ' +
        escapeCsvString(getEditValue(elementBySignature(omod, 'FULL'))) + ', ' +
        escapeCsvString(getEditValue(elementBySignature(omod, 'DESC'))) + ', ' +
        escapeCsvString(getEditValue(elementByName(data, 'Form Type'))) + ', ' +
        escapeCsvString(getEditValue(elementBySignature(omod, 'LNAM'))) + ', ' +
        escapeCsvString(getEditValue(elementByName(data, 'Attach Point'))) + ', ' +
        escapeCsvString(getJsonChildArray(elementByName(data, 'Attach Parent Slots'))) + ', ' +
        escapeCsvString(getJsonIncludesArray(data)) + ', ' +
        escapeCsvString(getJsonOMODPropertyObject(data)) + ', ' +
        escapeCsvString(getJsonChildArray(elementBySignature(omod, 'MNAM')))
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

    includes := elementByName(data, 'Includes');
    for i := 0 to elementCount(includes) - 1 do begin
        include := elementByIndex(includes, i);
        resultList.add(
            '{' +
            '"Mod":"' + escapeJson(getEditValue(elementByName(include, 'Mod'))) + '",' +
            '"Minimum Level":"' + escapeJson(getEditValue(elementByName(include, 'Minimum Level'))) + '",' +
            '"Optional":"' + escapeJson(getEditValue(elementByName(include, 'Optional'))) + '",' +
            '"Don''t Use All":"' + escapeJson(getEditValue(elementByName(include, 'Don''t Use All'))) + '"' +
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

    props := elementByName(data, 'Properties');
    for i := 0 to elementCount(props) - 1 do begin
        prop := elementByIndex(props, i);
        resultList.add(
            '{' +
            '"Value Type":"' + escapeJson(getEditValue(elementByName(prop, 'Value Type'))) + '",' +
            '"Function Type":"' + escapeJson(getEditValue(elementByName(prop, 'Function Type'))) + '",' +
            '"Property":"' + escapeJson(getEditValue(elementByName(prop, 'Property'))) + '",' +
            '"Value 1":"' + escapeJson(getEditValue(elementByName(prop, 'Value 1'))) + '",' +
            '"Value 2":"' + escapeJson(getEditValue(elementByName(prop, 'Value 2'))) + '",' +
            '"Curve Table":"' + escapeJson(getEditValue(elementByName(prop, 'Curve Table'))) + '"' +
            '}'
        );
    end;

    resultList.sort();
    result := listToJsonArray(resultList);
    resultList.free();
end;


end.
