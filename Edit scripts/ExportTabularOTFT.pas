unit ExportTabularOTFT;

uses ExportCore,
     ExportTabularCore,
     ExportJson;


var ExportTabularOTFT_outputLines: TStringList;


function initialize(): Integer;
begin
    ExportTabularOTFT_outputLines := TStringList.create();
    ExportTabularOTFT_outputLines.add(
            '"File"'       // Name of the originating ESM
        + ', "Form ID"'    // Form ID
        + ', "Editor ID"'  // Editor ID
        + ', "Items"'      // Sorted JSON array of items contained in the outfit
    );
end;

function canProcess(e: IInterface): Boolean;
begin
    result := signature(e) = 'OTFT';
end;

function process(otft: IInterface): Integer;
var acbs: IInterface;
    rnam: IInterface;
    aidt: IInterface;
    cnam: IInterface;
begin
    if not canProcess(otft) then begin
        addWarning(name(otft) + ' is not an OTFT. Entry was ignored.');
        exit;
    end;

    ExportTabularOTFT_outputLines.add(
          escapeCsvString(getFileName(getFile(otft))) + ', '
        + escapeCsvString(stringFormID(otft)) + ', '
        + escapeCsvString(evBySign(otft, 'EDID')) + ', '
        + escapeCsvString(getJsonChildArray(eBySign(otft, 'INAM')))
    );
end;

function finalize(): Integer;
begin
    createDir('dumps/');
    ExportTabularOTFT_outputLines.saveToFile('dumps/OTFT.csv');
    ExportTabularOTFT_outputLines.free();
end;


end.
