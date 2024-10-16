unit ExportTabularALCH;

uses ExportCore,
     ExportTabularCore,
     ExportJson;


var ExportTabularALCH_outputLines: TStringList;


function initialize(): Integer;
begin
    ExportTabularALCH_outputLines := TStringList.create();
    ExportTabularALCH_outputLines.add(
        '"File", ' +              // Name of the originating ESM
        '"Form ID", ' +           // Form ID
        '"Editor ID", ' +         // Editor ID
        '"Name", ' +              // Full name
        '"Description", ' +       // Description
        '"Weight", ' +            // Weight
        '"Value", ' +             // Value
        '"Flags", ' +             // Sorted list of flag names
        '"Addiction", ' +         // Editor ID of addiction (possibly null)
        '"Addiction chance", ' +  // Addiction chance
        '"Health", ' +            // Editor ID of health curve table (possibly null)
        '"Spoiled", ' +           // Editor ID of spoiled version (possibly null)
        '"Effects", ' +           // Unsorted array of effect objects. Conditions are not included
        '"Keywords"'              // Sorted JSON array of keywords. Each keyword is represented as
                                  // `{EditorID} [KYWD:{FormID}]`
    );
end;

function process(el: IInterface): Integer;
begin
    if signature(el) <> 'ALCH' then begin exit; end;

    _process(el);
end;

function _process(alch: IInterface): Integer;
var enit: IInterface;
    outputString: String;
begin
    enit := elementBySignature(alch, 'ENIT');

    outputString :=
        escapeCsvString(getFileName(getFile(alch))) + ', ' +
        escapeCsvString(stringFormID(alch)) + ', ' +
        escapeCsvString(getEditValue(elementBySignature(alch, 'EDID'))) + ', ' +
        escapeCsvString(getEditValue(elementBySignature(alch, 'FULL'))) + ', ' +
        escapeCsvString(getEditValue(elementBySignature(alch, 'DESC'))) + ', ' +
        escapeCsvString(getEditValue(elementBySignature(alch, 'DATA'))) + ', ' +
        escapeCsvString(getEditValue(elementByName(enit, 'Value'))) + ', ' +
        escapeCsvString(getJsonFlagArray(elementByName(enit, 'Flags'))) + ', ' +
        escapeCsvString(getEditValue(elementByName(enit, 'Addiction'))) + ', ' +
        escapeCsvString(getEditValue(elementByName(enit, 'Addiction Chance'))) + ', ' +
        escapeCsvString(getEditValue(elementByName(enit, 'Health'))) + ', ' +
        escapeCsvString(getEditValue(elementByName(enit, 'Spoiled'))) + ', ' +
        escapeCsvString(getJsonEffectsArray(elementByName(alch, 'Effects'))) + ', ' +
        escapeCsvString(getJsonChildArray(elementByPath(alch, 'Keywords\KWDA')));

    ExportTabularALCH_outputLines.add(outputString);
end;

function finalize(): Integer;
begin
    createDir('dumps/');
    ExportTabularALCH_outputLines.saveToFile('dumps/ALCH.csv');
    ExportTabularALCH_outputLines.free();
end;


(**
 * Returns a JSON array string of flag names in [flags], sorted, and with unknown flags filtered out.
 *
 * @param flags  the flags to return as a JSON array string
 * @return a JSON array string of flag names in [flags], sorted, and with unknown flags filtered out
 *)
function getJsonFlagArray(flags: IInterface): String;
var i: Integer;
    list: TStringList;
    filteredList: TStringList;
begin
    list := TStringList.create();
    list.text := flagValues(flags);

    filteredList := TStringList.create();
    for i := 1 to list.count - 1 do begin
        if (pos('Unknown', list[i]) = 0) then begin
            filteredList.add(list[i]);
        end;
    end;

    filteredList.sort();
    result := stringListToJsonArray(filteredList);

    filteredList.free();
    list.free();
end;


(**
 * Returns a JSON array string of the given [effects].
 *
 * @param effects  the effects to return as a JSON array string
 * @return a JSON array string of the given [effects]
 *)
function getJsonEffectsArray(effects: IInterface): String;
var i: Integer;
    effect: IInterface;
    efit: IInterface;
    magnitude: String;
    duration: String;
    resultList: TStringList;
begin

        // For some reason, magnitude and duration are stored in two places.
        // If both places are set, the one in `effect` takes precedence.

        // Properties MAGA, MAGF, EIES, and CODV are never used (as of 2023-06-17).

    resultList := TStringList.create();

    for i := 0 to elementCount(effects) - 1 do begin
        effect := elementByIndex(effects, i);
        efit := elementBySignature(effect, 'EFIT');

        if elementExists(effect, 'MAGG - Magnitude') then begin
            magnitude := getEditValue(elementBySignature(effect, 'MAGG'));
        end else if elementExists(efit, 'Magnitude') then begin
            magnitude := getEditValue(elementByName(efit, 'Magnitude'));
        end else begin
            magnitude := '';
        end;

        if elementExists(effect, 'DURG - Duration') then begin
            duration := getEditValue(elementBySignature(effect, 'DURG'));
        end else if elementExists(efit, 'Duration') then begin
            duration := getEditValue(elementByName(efit, 'Duration'));
        end else begin
            duration := '';
        end;

        resultList.add(
            '{' +
            '"Base Effect":"' + escapeJson(getEditValue(elementBySignature(effect, 'EFID'))) + '",' +
            '"Magnitude":"' + escapeJson(magnitude) + '",' +
            '"Duration":"' + escapeJson(duration) + '",' +
            '"Area":"' + escapeJson(getEditValue(elementByName(efit, 'Area'))) + '",' +
            '"Curve Table":"' + escapeJson(getEditValue(elementBySignature(effect, 'CVT0'))) + '"' +
            '}'
        );
    end;

    resultList.sort();
    result := listToJsonArray(resultList);
    resultList.free();
end;


end.
