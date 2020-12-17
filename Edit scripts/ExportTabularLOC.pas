(**
 * Framework of functions for exporting location data of records.
 *
 * This file does not actually produce dumps, but is used by several other files to help create location dumps.
 *)
unit ExportTabularLOC;


(**
 * Initializes a line buffer for locations data.
 *
 * @return a line buffer for locations
 *)
function initLocList(): TStringList;
begin
    result := TStringList.create();
    result.add(
            '"File"'         // Name of the originating ESM of the reference
        + ', "Ref Form ID"'  // Form ID of reference
        + ', "Form ID"'      // Form ID of item
        + ', "Editor ID"'    // Editor ID of item
        + ', "Name"'         // Full name of item
        + ', "Layer"'        // Layer the reference is linked to
        + ', "Cell"'         // World cell
        + ', "Position"'     // Vec3 position
        + ', "Rotation"'     // Vec3 rotation
    );
end;

(**
 * Appends to [locations] an entry for each location reference to [el].
 *
 * @param locations  the list to append location reference records to
 * @param el         the record to find the location reference data of
 *)
procedure appendLocationData(var locations: TStringList; el: IInterface);
var ref: IwbElement;
    data: IInterface;
    i: Integer;
begin
    for i := 0 to referencedByCount(el) - 1 do begin
        ref := referencedByIndex(el, i);
        data := eBySign(ref, 'DATA');

        if (signature(ref) <> 'REFR') or (not elementExists(data, 'Position')) then begin
            continue;
        end;

        locations.add(
              escapeCsvString(getFileName(getFile(ref))) + ', '
            + escapeCsvString(stringFormID(ref)) + ', '
            + escapeCsvString(stringFormID(el)) + ', '
            + escapeCsvString(evBySign(el, 'EDID')) + ', '
            + escapeCsvString(evBySign(el, 'FULL')) + ', '
            + escapeCsvString(evBySign(ref, 'XLYR')) + ', '
            + escapeCsvString(gev(ElementByName(ref, 'Cell'))) + ', '
            + escapeCsvString(vec3ToString(ElementByName(data,'Position'))) + ', '
            + escapeCsvString(vec3ToString(ElementByName(data,'Rotation')))
        );
    end;
end;

(**
 * Converts a vec3 to a string.
 *
 * @param vec3  the 3D vector to convert to a string
 * @return the X, Y, and Z of the vector, separated by colons
 *)
function vec3ToString(vec3: IInterface): String;
begin
    result := evByName(vec3, 'X') + ':' + evByName(vec3, 'Y') + ':' + evByName(vec3, 'Z');
end;


end.
