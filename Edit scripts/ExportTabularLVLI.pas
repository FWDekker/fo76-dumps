unit ExportTabularLVLI;

uses ExportCore,
     ExportTabularCore,
     ExportJson;


var ExportTabularLVLI_outputLines: TStringList;
var ExportTabularLOC_outputLines: TStringList;


function initialize(): Integer;
begin
    ExportTabularLVLI_outputLines := TStringList.create();
    ExportTabularLVLI_outputLines.add(
            '"File"'          // Name of the originating ESM
        + ', "Form ID"'       // Form ID
        + ', "Editor ID"'     // Editor ID
        + ', "Name"'          // Full name
        + ', "Leveled List"'  // Leveled list
    );


    ExportTabularLOC_outputLines := initializeLocationTabular();
end;

function canProcess(e: IInterface): Boolean;
begin
    result := signature(e) = 'LVLI';
end;

function process(lvli: IInterface): Integer;
var data: IInterface;
begin
    if not canProcess(lvli) then begin
        addWarning(name(lvli) + ' is not a LVLI. Entry was ignored.');
        exit;
    end;

    data := eBySign(lvli, 'DATA');
    ExportTabularLVLI_outputLines.add(
          escapeCsvString(getFileName(getFile(lvli))) + ', '
        + escapeCsvString(stringFormID(lvli)) + ', '
        + escapeCsvString(evBySign(lvli, 'EDID')) + ', '
        + escapeCsvString(evBySign(lvli, 'FULL')) + ', '
        + escapeCsvString(getJsonLeveledListArray(lvli))
    );

    ExportTabularLOC_outputLines.addStrings(getLocationData(lvli));
end;

function finalize(): Integer;
begin
    createDir('dumps/');
    ExportTabularLVLI_outputLines.saveToFile('dumps/LVLI.csv');
    ExportTabularLOC_outputLines.saveToFile('dumps/LVLILOC.csv');
    ExportTabularLOC_outputLines.free();
    ExportTabularLVLI_outputLines.free();
end;


end.
