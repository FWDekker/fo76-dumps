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
            '"File"'        // Name of the originating ESM
        + ', "Form ID"'     // Form ID
        + ', "Editor ID"'   // Editor ID
        + ', "Name"'        // Full name
        + ', "Weight"'      // Item weight in pounds
        + ', "Value"'       // Item value in bottlecaps
        + ', "Components"'  // Sorted JSON array of the components needed to craft. Each component is formatted as
                            // `[component editor id] ([amount])`
    );
    ExportTabularMISC_LOC_outputLines := initLocList();
end;

function canProcess(e: IInterface): Boolean;
begin
    result := signature(e) = 'MISC';
end;

function process(misc: IInterface): Integer;
begin
    if not canProcess(misc) then begin
        addWarning(name(misc) + ' is not a MISC. Entry was ignored.');
        exit;
    end;

    ExportTabularMISC_outputLines.add(
          escapeCsvString(getFileName(getFile(misc))) + ', '
        + escapeCsvString(stringFormID(misc)) + ', '
        + escapeCsvString(evBySign(misc, 'EDID')) + ', '
        + escapeCsvString(evBySign(misc, 'FULL')) + ', '
        + escapeCsvString(evByPath(eBySign(misc, 'DATA'), 'Weight')) + ', '
        + escapeCsvString(evByPath(eBySign(misc, 'DATA'), 'Value')) + ', '
        + escapeCsvString(getJsonComponentArray(misc))
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
 * Returns the components of [e] as a comma-separated list of editor IDs and counts.
 *
 * @param e  the element to return the components of
 * @return the components of [e] as a comma-separated list of editor IDs and counts
 *)
function getJsonComponentArray(e: IInterface): String;
var i: Integer;
    components: IInterface;
    component: IInterface;
    quantity: IInterface;
    resultList: TStringList;
begin
    resultList := TStringList.create();

    components := eBySign(e, 'MCQP');
    for i := 0 to eCount(components) - 1 do begin
        component := linkByName(eByIndex(components, i), 'Component');
        quantity := linkByName(eByIndex(components, i), 'Component Count Keyword');

        resultList.add(
              evBySign(component, 'EDID')
            + ' (' + intToStr(quantityKeywordToValue(component, quantity)) + ')'
        );
    end;

    resultList.sort();
    result := stringListToJsonArray(resultList);
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
    quantityName := evBySign(quantity, 'EDID');
    componentQuantities := eBySign(component, 'CVPA');

    for i := 0 to eCount(componentQuantities) - 1 do begin
        componentQuantity := eByIndex(componentQuantities, i);

        if
            strEquals(
                quantityName,
                evBySign(linkByName(componentQuantity, 'Scrap Count Keyword'), 'EDID')
            )
        then begin
            result := evByName(componentQuantity, 'Scrap Component Count');
            break;
        end;
    end;
end;


end.
