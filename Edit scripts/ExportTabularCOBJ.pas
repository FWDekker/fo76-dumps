unit ExportTabularCOBJ;

uses ExportCore,
     ExportTabularCore;


var ExportTabularCOBJ_outputLines: TStringList;


function initialize: Integer;
begin
    ExportTabularCOBJ_outputLines := TStringList.create;
    ExportTabularCOBJ_outputLines.add('"File", "Form ID", "Editor ID", "Product form ID", "Product editor ID", "Product name", "Recipe form ID", "Recipe editor ID", "Recipe name", "Components"');
end;

function canProcess(e: IInterface): Boolean;
begin
    result := signature(e) = 'COBJ';
end;

function process(cobj: IInterface): Integer;
var product: IInterface;
    recipe: IInterface;
begin
    if not canProcess(cobj) then begin
        addMessage('Warning: ' + name(cobj) + ' is not a COBJ. Entry was ignored.');
        exit;
    end;

    product := linksTo(eBySignature(cobj, 'CNAM'));
    recipe := linksTo(eBySignature(cobj, 'GNAM'));

    ExportTabularCOBJ_outputLines.add(
        escapeCsvString(getFileName(getFile(cobj))) + ', ' +
        escapeCsvString(stringFormID(cobj)) + ', ' +
        escapeCsvString(evBySignature(cobj, 'EDID')) + ', ' +
        escapeCsvString(ifThen(not assigned(product), '', stringFormID(product))) + ', ' +
        escapeCsvString(ifThen(not assigned(product), '', evBySignature(product, 'EDID'))) + ', ' +
        escapeCsvString(ifThen(not assigned(product), '', evBySignature(product, 'FULL'))) + ', ' +
        escapeCsvString(ifThen(not assigned(recipe), '', stringFormID(recipe))) + ', ' +
        escapeCsvString(ifThen(not assigned(recipe), '', evBySignature(recipe, 'EDID'))) + ', ' +
        escapeCsvString(ifThen(not assigned(recipe), '', evBySignature(recipe, 'FULL'))) + ', ' +
        escapeCsvString(getFlatComponentList(cobj))
    );
end;

function finalize: Integer;
begin
    createDir('dumps/');
    ExportTabularCOBJ_outputLines.saveToFile('dumps/COBJ.csv');
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
begin
    components := eBySignature(e, 'FVPA');
    if eCount(components) = 0 then begin
        result := '';
        exit;
    end;

    result := ',';
    for i := 0 to eCount(components) - 1 do begin
        component := eByIndex(components, i);
        result := result
            + evBySignature(linksTo(eByPath(component, 'Component')), 'EDID')
            + ' (' + intToStr(evByPath(component, 'Count')) + '),';
    end;
end;


end.
