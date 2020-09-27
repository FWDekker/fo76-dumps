unit ExportTabularLVLI;

uses ExportCore,
     ExportTabularCore,
     ExportJson,
     ExportTabularLOC;


var ExportTabularLVLI_outputLines: TStringList;
var ExportTabularLVLI_LOC_outputLines: TStringList;


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

    ExportTabularLVLI_LOC_outputLines := initLocList();
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

    appendLocationData(ExportTabularLVLI_LOC_outputLines, lvli);
end;

function finalize(): Integer;
begin
    createDir('dumps/');

    ExportTabularLVLI_outputLines.saveToFile('dumps/LVLI.csv');
    ExportTabularLVLI_outputLines.free();

    ExportTabularLVLI_LOC_outputLines.saveToFile('dumps/LVLI_LOC.csv');
    ExportTabularLVLI_LOC_outputLines.free();
end;


end.
