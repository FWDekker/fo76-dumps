unit ExportTabularENTM;

uses ExportCore,
     ExportTabularCore,
     ExportJson;


var ExportTabularENTM_outputLines: TStringList;


function initialize(): Integer;
begin
    ExportTabularENTM_outputLines := TStringList.create();
    ExportTabularENTM_outputLines.add(
            '"File"'                           // Name of the originating ESM
        + ', "Form ID"'                        // Form ID
        + ', "Editor ID"'                      // Editor ID
        + ', "Name (FULL)"'                    // Full name
        + ', "Name (NNAM)"'                    // Shortened name
        + ', "Description"'                    // Description
        + ', "Storefront image path"'          // Path to where images are located
        + ', "Storefront image preview"'       // File name of preview image
        + ', "Storefront confirm image list"'  // Sorted JSON array of file names
        + ', "Keywords"'                       // Sorted JSON array of keywords. Each keyword is represented as
                                               // `{EditorID} [KYWD:{FormID}]`
    );
end;

function canProcess(el: IInterface): Boolean;
begin
    result := signature(el) = 'ENTM';
end;

function process(entm: IInterface): Integer;
begin
    if not canProcess(entm) then begin
        addWarning(name(entm) + ' is not an ENTM. Entry was ignored.');
        exit;
    end;

    ExportTabularENTM_outputLines.add(
          escapeCsvString(getFileName(getFile(entm))) + ', '
        + escapeCsvString(stringFormID(entm)) + ', '
        + escapeCsvString(evBySign(entm, 'EDID')) + ', '
        + escapeCsvString(evBySign(entm, 'FULL')) + ', '
        + escapeCsvString(evBySign(entm, 'NNAM')) + ', '
        + escapeCsvString(evBySign(entm, 'DESC')) + ', '
        + escapeCsvString(evBySign(entm, 'ETIP')) + ', '
        + escapeCsvString(evBySign(entm, 'ETDI')) + ', '
        + escapeCsvString(getJsonChildArray(eByName(entm, 'Storefront Confirm Image List'))) + ', '
        + escapeCsvString(getJsonChildArray(eByPath(entm, 'Keywords\KWDA')))
    );
end;

function finalize(): Integer;
begin
    createDir('dumps/');
    ExportTabularENTM_outputLines.saveToFile('dumps/ENTM.csv');
    ExportTabularENTM_outputLines.free();
end;


end.
