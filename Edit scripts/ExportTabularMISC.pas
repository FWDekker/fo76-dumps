unit ExportTabularMISC;

uses ExportCore,
     ExportTabularCore,
     ExportJson,
     ExportTabularLOC;


var ExportTabularMISC_outputLines: TStringList;
var ExportTabularMISC_LOC_outputLines: TStringList;


function initialize(): Integer;
begin
    ExportTabularMISC_outputLines := TStringList.create();
    ExportTabularMISC_outputLines.add(
        '"File", ' +       // Name of the originating ESM
        '"Form ID", ' +    // Form ID
        '"Editor ID", ' +  // Editor ID
        '"Name", ' +       // Full name
        '"Weight", ' +     // Item weight in pounds
        '"Value", ' +      // Item value in bottlecaps
        '"Components"'     // Sorted JSON array of the components needed to craft. Each component is represented by a
                           // JSON object containing the component identifier and the count
    );
    ExportTabularMISC_LOC_outputLines := initLocList();
end;

function process(el: IInterface): Integer;
begin
    if signature(el) <> 'MISC' then begin exit; end;

    _process(el);
end;

function _process(misc: IInterface): Integer;
begin
    ExportTabularMISC_outputLines.add(
        escapeCsvString(getFileName(getFile(misc))) + ', ' +
        escapeCsvString(stringFormID(misc)) + ', ' +
        escapeCsvString(getEditValue(elementBySignature(misc, 'EDID'))) + ', ' +
        escapeCsvString(getEditValue(elementBySignature(misc, 'FULL'))) + ', ' +
        escapeCsvString(getEditValue(elementByPath(misc, 'DATA\Weight'))) + ', ' +
        escapeCsvString(getEditValue(elementByPath(misc, 'DATA\Value'))) + ', ' +
        escapeCsvString(getJsonComponentArray(misc))
    );

    appendLocationData(ExportTabularMISC_LOC_outputLines, misc);
end;

function finalize(): Integer;
begin
    createDir('dumps/');

    ExportTabularMISC_outputLines.saveToFile('dumps/MISC.csv');
    ExportTabularMISC_outputLines.free();

    ExportTabularMISC_LOC_outputLines.saveToFile('dumps/MISC_LOC.csv');
    ExportTabularMISC_LOC_outputLines.free();
end;


(**
 * Returns the components of [el] as a comma-separated list of identifiers and counts.
 *
 * @param el  the element to return the components of
 * @return the components of [el] as a comma-separated list of identifiers and counts
 *)
function getJsonComponentArray(el: IInterface): String;
var i: Integer;
    components: IInterface;
    entry: IInterface;
    component: IInterface;
    quantity: IInterface;
    resultList: TStringList;
begin
    resultList := TStringList.create();

    components := elementBySignature(el, 'MCQP');
    for i := 0 to elementCount(components) - 1 do begin
        entry := elementByIndex(components, i);
        component := elementByName(entry, 'Component');
        quantity := elementByName(entry, 'Component Count Keyword');

        resultList.add(
            '{' +
            '"Component":"' + escapeJson(getEditValue(component)) + '",' +
            '"Component Count Keyword":"' + escapeJson(getEditValue(quantity)) + '",' +
            '"Count":"' + escapeJson(intToStr(quantityKeywordToValue(linksTo(component), linksTo(quantity)))) + '"' +
            '}'
        );
    end;

    resultList.sort();
    result := listToJsonArray(resultList);
    resultList.free();
end;

(**
 * Returns the number of items the quantity keyword [quantity] signifies for [component].
 *
 * @param component  the component to look up the quantity in
 * @param quantity   the quantity keyword to look up in [component]
 * @return the number of items the quantity keyword [quantity] signifies for [component]
 *)
function quantityKeywordToValue(component: IInterface; quantity: IInterface): Integer;
var i: Integer;
    quantityName: String;
    componentQuantities: IInterface;
    componentQuantity: IInterface;
begin
    quantityName := getEditValue(elementBySignature(quantity, 'EDID'));
    componentQuantities := elementBySignature(component, 'CVPA');

    for i := 0 to elementCount(componentQuantities) - 1 do begin
        componentQuantity := elementByIndex(componentQuantities, i);

        if
            strEquals(
                quantityName,
                getEditValue(
                    elementBySignature(linksTo(elementByName(componentQuantity, 'Scrap Count Keyword')), 'EDID')
                )
            )
        then begin
            result := getEditValue(elementByName(componentQuantity, 'Scrap Component Count'));
            break;
        end;
    end;
end;


end.
