unit ExportTabularCOBJ;

uses ExportCore,
     ExportTabularCore;


var outputLines: TStringList;


function initialize: Integer;
begin
    outputLines := TStringList.create;
    outputLines.add('"Form ID", "Editor ID", "Created item form ID", "Recipe form ID", "Components"');
end;

function process(e: IInterface): Integer;
var cnam: IInterface;
    gnam: IInterface;
begin
    if signature(e) <> 'COBJ' then begin
        addMessage('Warning: ' + name(e) + ' is not a COBJ. Entry was ignored.');
        exit;
    end;

    cnam := linksTo(eBySignature(e, 'CNAM'));
    gnam := linksTo(eBySignature(e, 'GNAM'));

    outputLines.add(
        escapeCsvString(stringFormID(e)) + ', ' +
        escapeCsvString(evBySignature(e, 'EDID')) + ', ' +
        escapeCsvString(ifThen(not assigned(cnam), '', stringFormID(cnam))) + ', ' +
        escapeCsvString(ifThen(not assigned(gnam), '', stringFormID(gnam))) + ', ' +
        escapeCsvString(getFlatComponentList(e))
    );
end;

function finalize: Integer;
begin
    createDir('dumps/');
    outputLines.saveToFile('dumps/COBJ.csv');
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
