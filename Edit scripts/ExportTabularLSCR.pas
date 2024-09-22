unit ExportTabularLSCR;

uses ExportCore,
     ExportTabularCore;


var ExportTabularLSCR_outputLines: TStringList;


function initialize(): Integer;
begin
    ExportTabularLSCR_outputLines := TStringList.create();
    ExportTabularLSCR_outputLines.add(
            '"File"'              // Name of the originating ESM
        + ', "Form ID"'           // Form ID
        + ', "Editor ID"'         // Editor ID
        + ', "Description"'       // (English) flavor text
        + ', "Background image"'  // Path to file displayed in background
        + ', "Foreground model"'  // Link to 'STAT' record displayed in foreground
    );
end;

function canProcess(el: IInterface): Boolean;
begin
    result := signature(el) = 'LSCR';
end;

function process(LSCR: IInterface): Integer;
begin
    if not canProcess(LSCR) then begin
        addWarning(name(LSCR) + ' is not an LSCR. Entry was ignored.');
        exit;
    end;

    ExportTabularLSCR_outputLines.add(
          escapeCsvString(getFileName(getFile(LSCR))) + ', '
        + escapeCsvString(stringFormID(LSCR)) + ', '
        + escapeCsvString(evBySign(LSCR, 'EDID')) + ', '
        + escapeCsvString(evBySign(LSCR, 'DESC')) + ', '
        + escapeCsvString(evBySign(LSCR, 'BNAM')) + ', '
        + escapeCsvString(evBySign(LSCR, 'NNAM'))
    );
end;

function finalize(): Integer;
begin
    createDir('dumps/');
    ExportTabularLSCR_outputLines.saveToFile('dumps/LSCR.csv');
    ExportTabularLSCR_outputLines.free();
end;


end.
