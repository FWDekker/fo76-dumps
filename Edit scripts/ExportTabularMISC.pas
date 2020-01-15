unit ExportTabularMISC;

uses ExportCore,
     ExportTabularCore;


var ExportTabularMISC_outputLines: TStringList;


function initialize: Integer;
begin
    ExportTabularMISC_outputLines := TStringList.create;
    ExportTabularMISC_outputLines.add('"File", "Form ID", "Editor ID", "Item name", "Weight", "Value", "Components"');
end;

function canProcess(e: IInterface): Boolean;
begin
    result := signature(e) = 'MISC';
end;

function process(misc: IInterface): Integer;
begin
    if not canProcess(misc) then begin
        addMessage('Warning: ' + name(misc) + ' is not a MISC. Entry was ignored.');
        exit;
    end;

    ExportTabularMISC_outputLines.add(
        escapeCsvString(getFileName(getFile(misc))) + ', ' +
        escapeCsvString(stringFormID(misc)) + ', ' +
        escapeCsvString(evBySign(misc, 'EDID')) + ', ' +
        escapeCsvString(evBySign(misc, 'FULL')) + ', ' +
        escapeCsvString(evByPath(eBySign(misc, 'DATA'), 'Weight')) + ', ' +
        escapeCsvString(evByPath(eBySign(misc, 'DATA'), 'Value')) + ', ' +
        escapeCsvString(getFlatComponentList(misc))
    );
end;

function finalize: Integer;
begin
    createDir('dumps/');
    ExportTabularMISC_outputLines.saveToFile('dumps/MISC.csv');
end;


(**
 * Returns the components of [e] as a comma-separated list of editor IDs and counts.
 *
 * @param e the element to return the components of
 * @return the components of [e] as a comma-separated list of editor IDs and counts
 *)
function getFlatComponentList(e: IInterface): String;
var i: Integer;
    components: IInterface;
    component: IInterface;
    quantity: IInterface;
begin
    components := eBySign(e, 'MCQP');
    if eCount(components) = 0 then begin
        exit('');
    end;

    result := ',';
    for i := 0 to eCount(components) - 1 do begin
        component := linkByName(eByIndex(components, i), 'Component');
        quantity := linkByName(eByIndex(components, i), 'Component Count Keyword');

        result := result
            + evBySign(component, 'EDID')
            + ' (' + intToStr(quantityKeywordToValue(component, quantity)) + '),';
    end;
end;

(**
 * Returns the number of items the quantity keyword [quantity] signifies for [component].
 *
 * @param component the component to look up the quantity in
 * @param quantity  the quantity keyword to look up in [component]
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
