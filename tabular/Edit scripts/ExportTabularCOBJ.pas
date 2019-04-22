unit ExportTabularCOBJ;

uses ExportCore,
     ExportTabularCore;


var outputLines: TStringList;


function Initialize: integer;
begin
    outputLines := TStringList.Create;
    outputLines.Add('"Form ID", "Editor ID", "Created item form ID", "Recipe form ID", "Components"');
end;

function Process(e: IInterface): integer;
var cnam: IInterface;
    gnam: IInterface;
begin
    cnam := LinksTo(eBySignature(e, 'CNAM'));
    gnam := LinksTo(eBySignature(e, 'GNAM'));

    outputLines.Add(
        EscapeCsvString(StringFormID(e)) + ', ' +
        EscapeCsvString(evBySignature(e, 'EDID')) + ', ' +
        EscapeCsvString(IfThen(not Assigned(cnam), '', StringFormID(cnam))) + ', ' +
        EscapeCsvString(IfThen(not Assigned(gnam), '', StringFormID(gnam))) + ', ' +
        EscapeCsvString(GetFlatComponentList(e))
    );
end;

function Finalize: integer;
begin
    CreateDir('dumps/');
    outputLines.SaveToFile('dumps/COBJ.csv');
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
begin
    components := eBySignature(e, 'FVPA');
    if (eCount(components) = 0) then
    begin
        Result := '';
        Exit;
    end;

    Result := ',';
    for i := 0 to eCount(components) - 1 do
    begin
        component := eByIndex(components, i);
        Result := Result + evBySignature(LinksTo(eByPath(component, 'Component')), 'EDID') + ' (' + IntToStr(evByPath(component, 'Count')) + '),';
    end;
end;


end.
