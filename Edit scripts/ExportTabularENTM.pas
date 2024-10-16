unit ExportTabularENTM;

uses ExportCore,
     ExportTabularCore,
     ExportJson;


var ExportTabularENTM_outputLines: TStringList;


function initialize(): Integer;
begin
    ExportTabularENTM_outputLines := TStringList.create();
    ExportTabularENTM_outputLines.add(
        '"File", ' +                           // Name of the originating ESM
        '"Form ID", ' +                        // Form ID
        '"Editor ID", ' +                      // Editor ID
        '"Name (FULL)", ' +                    // Full name
        '"Name (NNAM)", ' +                    // Shortened name
        '"Description", ' +                    // Description
        '"Storefront image path", ' +          // Path to where images are located
        '"Storefront image preview", ' +       // File name of preview image
        '"Storefront confirm image list", ' +  // Sorted JSON array of file names
        '"Keywords"'                           // Sorted JSON array of keywords. Each keyword is represented as
                                               // `{EditorID} [KYWD:{FormID}]`
    );
end;

function process(el: IInterface): Integer;
begin
    if signature(el) <> 'ENTM' then begin exit; end;

    _process(el);
end;

function _process(entm: IInterface): Integer;
begin
    ExportTabularENTM_outputLines.add(
        escapeCsvString(getFileName(getFile(entm))) + ', ' +
        escapeCsvString(stringFormID(entm)) + ', ' +
        escapeCsvString(getEditValue(elementBySignature(entm, 'EDID'))) + ', ' +
        escapeCsvString(getEditValue(elementBySignature(entm, 'FULL'))) + ', ' +
        escapeCsvString(getEditValue(elementBySignature(entm, 'NNAM'))) + ', ' +
        escapeCsvString(getEditValue(elementBySignature(entm, 'DESC'))) + ', ' +
        escapeCsvString(getEditValue(elementBySignature(entm, 'ETIP'))) + ', ' +
        escapeCsvString(getEditValue(elementBySignature(entm, 'ETDI'))) + ', ' +
        escapeCsvString(getJsonChildArray(elementByName(entm, 'Storefront Confirm Image List'))) + ', ' +
        escapeCsvString(getJsonChildArray(elementByPath(entm, 'Keywords\KWDA')))
    );
end;

function finalize(): Integer;
begin
    createDir('dumps/');
    ExportTabularENTM_outputLines.saveToFile('dumps/ENTM.csv');
    ExportTabularENTM_outputLines.free();
end;


end.
