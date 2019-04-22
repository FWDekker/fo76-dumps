unit ExportTabularSCRAP;

uses ExportCore,
     ExportTabularCore;


var outputLines: TStringList;


function Initialize: integer;
begin
    outputLines := TStringList.Create;
    outputLines.Add('"Form ID", "Editor ID", "Item name", "Components"');
end;

function Process(e: IInterface): integer;
begin
    outputLines.Add(
        EscapeCsvString(StringFormID(e)) + ', ' +
        EscapeCsvString(evBySignature(e, 'EDID')) + ', ' +
        EscapeCsvString(evBySignature(e, 'FULL')) + ', ' +
        EscapeCsvString(GetFlatComponentList(e))
    );
end;

function Finalize: integer;
begin
    CreateDir('dumps/');
    outputLines.SaveToFile('dumps/SCRAP.csv');
end;


(**
 * Returns the components of [e] as a comma-separated list of editor IDs and counts.
 *
 * @param e the element to return the components of
 * @return the components of [e] as a comma-separated list of editor IDs and counts
 *)
function GetFlatComponentList(e: IInterface): string;
var i: integer;
    components: IInterface;
    component: IInterface;
    quantity: IInterface;
begin
    components := eBySignature(e, 'MCQP');
    if (eCount(components) = 0) then
    begin
        Result := '';
        Exit;
    end;

    Result := ',';
    for i := 0 to eCount(components) - 1 do
    begin
        component := LinksTo(eByName(eByIndex(components, i), 'Component'));
        quantity := LinksTo(eByName(eByIndex(components, i), 'Component Count Keyword'));

        Result := Result + evBySignature(component, 'EDID') + ' (' + IntToStr(QuantityKeywordToValue(component, quantity)) + '),';
    end;
end;

(**
 * Returns the number of items the quantity keyword [quantity] signifies for [component].
 *
 * @param component the component to look up the quantity in
 * @param quantity  the quantity keyword to look up in [component]
 * @return the number of items the quantity keyword [quantity] signifies for [component]
 *)
function QuantityKeywordToValue(component: IInterface; quantity: IInterface): integer;
var i: integer;
    quantityName: string;
    componentQuantities: IInterface;
    componentQuantity: IInterface;
begin
    quantityName := evBySignature(quantity, 'EDID');
    componentQuantities := eBySignature(component, 'CVPA');

    for i := 0 to eCount(componentQuantities) - 1 do
    begin
        componentQuantity := eByIndex(componentQuantities, i);

        if (CompareStr(quantityName, evBySignature(LinksTo(eByName(componentQuantity, 'Scrap Count Keyword')), 'EDID')) = 0) then
        begin
            Result := evByName(componentQuantity, 'Scrap Component Count');
            Break;
        end;
    end;
end;


end.
