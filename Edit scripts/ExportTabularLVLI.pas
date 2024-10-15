unit ExportTabularLVLI;

uses ExportCore,
     ExportTabularCore,
     ExportJson,
     ExportTabularLOC;


var ExportTabularLVLI_outputLines: TStringList;
var ExportTabularLVLI_LOC_outputLines: TStringList;


function initialize(): Integer;
begin
    ExportTabularLVLI_outputLines := TStringList.create();
    ExportTabularLVLI_outputLines.add(
        '"File", ' +       // Name of the originating ESM
        '"Form ID", ' +    // Form ID
        '"Editor ID", ' +  // Editor ID
        '"Name", ' +       // Full name
        '"Leveled List"'   // Leveled list
    );

    ExportTabularLVLI_LOC_outputLines := initLocList();
end;

function process(el: IInterface): Integer;
begin
    if signature(el) <> 'LVLI' then begin exit; end;

    _process(el);
end;

function _process(lvli: IInterface): Integer;
var data: IInterface;
begin
    data := elementBySignature(lvli, 'DATA');
    ExportTabularLVLI_outputLines.add(
        escapeCsvString(getFileName(getFile(lvli))) + ', ' +
        escapeCsvString(stringFormID(lvli)) + ', ' +
        escapeCsvString(getEditValue(elementBySignature(lvli, 'EDID'))) + ', ' +
        escapeCsvString(getEditValue(elementBySignature(lvli, 'FULL'))) + ', ' +
        escapeCsvString(getJsonLeveledListArray(lvli))
    );

    appendLocationData(ExportTabularLVLI_LOC_outputLines, lvli);
end;

function finalize(): Integer;
begin
    createDir('dumps/');

    ExportTabularLVLI_outputLines.saveToFile('dumps/LVLI.csv');
    ExportTabularLVLI_outputLines.free();

    ExportTabularLVLI_LOC_outputLines.saveToFile('dumps/LVLI_LOC.csv');
    ExportTabularLVLI_LOC_outputLines.free();
end;


(**
 * Returns the leveled list entries of [el] as a serialized JSON array.
 *
 * Each leveled list entry is expressed using a JSON object containing the item, the level, and the count.
 *
 * @param el  the element to return the leveled list entries of
 * @return the entries of [el] as a serialized JSON array
 *)
function getJsonLeveledListArray(el: IInterface): String;
var i: Integer;
    entries: IInterface;
    entry: IInterface;
    lvlo: IInterface;
    baseData: IInterface;
    resultList: TStringList;
begin
    resultList := TStringList.create();

    entries := elementByName(el, 'Leveled List Entries');
    for i := 0 to elementCount(entries) - 1 do begin
        entry := elementByIndex(entries, i);
        lvlo := elementBySignature(entry, 'LVLO');
        baseData := elementByName(lvlo, 'Base Data');

        if assigned(baseData) then begin
            resultList.add(
                '{' +
                '"Reference":"' + escapeJson(getEditValue(elementByName(baseData, 'Reference'))) + '",' +
                '"Level":"' + escapeJson(getEditValue(elementByName(baseData, 'Level'))) + '",' +
                '"Count":"' + escapeJson(getEditValue(elementByName(baseData, 'Count'))) + '",' +
                '"Chance None":"' + escapeJson(getEditValue(elementByName(baseData, 'Chance None'))) + '"' +
                '}'
            );
        end else begin
            resultList.add(
                '{' +
                '"Reference":"' + escapeJson(getEditValue(elementByName(lvlo, 'Reference'))) + '",' +
                '"Minimum Level":"' + escapeJson(getEditValue(elementBySignature(entry, 'LVLV'))) + '",' +
                '"Count":"' + escapeJson(getEditValue(elementBySignature(entry, 'LVIV'))) + '",' +
                '"Chance None":"' + escapeJson(getEditValue(elementBySignature(entry, 'LVOV'))) + '"' +
                '}'
            );
        end;
    end;

    resultList.sort();
    result := listToJsonArray(resultList);
    resultList.free();
end;


end.
