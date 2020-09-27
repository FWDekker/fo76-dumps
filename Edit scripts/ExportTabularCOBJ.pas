unit ExportTabularCOBJ;

uses ExportCore,
     ExportTabularCore,
     ExportJson;


var ExportTabularCOBJ_outputLines: TStringList;


function initialize: Integer;
begin
    ExportTabularCOBJ_outputLines := TStringList.create();
    ExportTabularCOBJ_outputLines.add(
            '"File"'              // Name of the originating ESM
        + ', "Form ID"'           // Form ID
        + ', "Editor ID"'         // Editor ID
        + ', "Product form ID"'   // Form ID of the product, or an empty string if there is no product
        + ', "Product editor ID"' // Editor ID of the product, or an empty string if there is no product
        + ', "Product name"'      // Full name of the product, or an empty string if there is no product
        + ', "Recipe form ID"'    // Form ID of the recipe, or an empty string if there is no recipe
        + ', "Recipe editor ID"'  // Editor ID of the recipe, or an empty string if there is no recipe
        + ', "Recipe name"'       // Full name of the recipe, or an empty string if there is no recipe
        + ', "Components"'        // Sorted JSON array of the components needed to craft. Each component is formatted as
                                  // `[editor id] ([amount])`
    );
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

    product := linkBySign(cobj, 'CNAM');
    recipe := linkBySign(cobj, 'GNAM');

    ExportTabularCOBJ_outputLines.add(
          escapeCsvString(getFileName(getFile(cobj))) + ', '
        + escapeCsvString(stringFormID(cobj)) + ', '
        + escapeCsvString(evBySign(cobj, 'EDID')) + ', '
        + escapeCsvString(ifThen(not assigned(product), '', stringFormID(product))) + ', '
        + escapeCsvString(ifThen(not assigned(product), '', evBySign(product, 'EDID'))) + ', '
        + escapeCsvString(ifThen(not assigned(product), '', evBySign(product, 'FULL'))) + ', '
        + escapeCsvString(ifThen(not assigned(recipe), '', stringFormID(recipe))) + ', '
        + escapeCsvString(ifThen(not assigned(recipe), '', evBySign(recipe, 'EDID'))) + ', '
        + escapeCsvString(ifThen(not assigned(recipe), '', evBySign(recipe, 'FULL'))) + ', '
        + escapeCsvString(getJsonComponentArray(cobj))
    );
end;

function finalize: Integer;
begin
    createDir('dumps/');
    ExportTabularCOBJ_outputLines.saveToFile('dumps/COBJ.csv');
    ExportTabularCOBJ_outputLines.free();
end;


end.
