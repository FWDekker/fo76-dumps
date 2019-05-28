unit ExportTabularMISC;

uses ExportCore,
     ExportTabularCore;


var outputLines: TStringList;


function initialize: Integer;
begin
    outputLines := TStringList.create;
    outputLines.add('"Form ID", "Editor ID", "Item name", "Weight", "Value", "Components"');
end;

function process(e: IInterface): Integer;
begin
    outputLines.add(
        escapeCsvString(stringFormID(e)) + ', ' +
        escapeCsvString(evBySignature(e, 'EDID')) + ', ' +
        escapeCsvString(evBySignature(e, 'FULL')) + ', ' +
        escapeCsvString(evByPath(eBySignature(e, 'DATA'), 'Weight')) + ', ' +
        escapeCsvString(evByPath(eBySignature(e, 'DATA'), 'Value')) + ', ' +
        escapeCsvString(getFlatComponentList(e))
    );
end;

function finalize: Integer;
begin
    createDir('dumps/');
    outputLines.saveToFile('dumps/MISC.csv');
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
    components := eBySignature(e, 'MCQP');
    if (eCount(components) = 0) then
    begin
        result := '';
        exit;
    end;

    result := ',';
    for i := 0 to eCount(components) - 1 do
    begin
        component := linksTo(eByName(eByIndex(components, i), 'Component'));
        quantity := linksTo(eByName(eByIndex(components, i), 'Component Count Keyword'));

        result := result + evBySignature(component, 'EDID') + ' (' + intToStr(quantityKeywordToValue(component, quantity)) + '),';
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
    quantityName := evBySignature(quantity, 'EDID');
    componentQuantities := eBySignature(component, 'CVPA');

    for i := 0 to eCount(componentQuantities) - 1 do
    begin
        componentQuantity := eByIndex(componentQuantities, i);

        if (compareStr(quantityName, evBySignature(linksTo(eByName(componentQuantity, 'Scrap Count Keyword')), 'EDID')) = 0) then
        begin
            result := evByName(componentQuantity, 'Scrap Component Count');
            break;
        end;
    end;
end;


end.
