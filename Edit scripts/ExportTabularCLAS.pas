unit ExportTabularCLAS;

uses ExportCore,
     ExportTabularCore,
     ExportJson;


var ExportTabularCLAS_outputLines: TStringList;


function initialize(): Integer;
begin
    ExportTabularCLAS_outputLines := TStringList.create();
    ExportTabularCLAS_outputLines.add(
            '"File"'        // Name of the originating ESM
        + ', "Form ID"'     // Form ID
        + ', "Editor ID"'   // Editor ID
        + ', "Name"'        // Full name
        + ', "Properties"'  // Sorted JSON object of properties
    );
end;

function process(el: IInterface): Integer;
begin
    if signature(el) <> 'CLAS' then begin exit; end;

    _process(el);
end;

function _process(clas: IInterface): Integer;
var acbs: IInterface;
    rnam: IInterface;
    aidt: IInterface;
    cnam: IInterface;
begin
    acbs := eBySign(clas, 'ACBS');
    rnam := linkBySign(clas, 'RNAM');
    aidt := eBySign(clas, 'AIDT');
    cnam := linkBySign(clas, 'CNAM');

    ExportTabularCLAS_outputLines.add(
          escapeCsvString(getFileName(getFile(clas))) + ', '
        + escapeCsvString(stringFormID(clas)) + ', '
        + escapeCsvString(evBySign(clas, 'EDID')) + ', '
        + escapeCsvString(evBySign(clas, 'FULL')) + ', '
        + escapeCsvString(getJsonPropertyObject(clas))
    );
end;

function finalize(): Integer;
begin
    createDir('dumps/');
    ExportTabularCLAS_outputLines.saveToFile('dumps/CLAS.csv');
    ExportTabularCLAS_outputLines.free();
end;


end.
