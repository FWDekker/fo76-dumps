unit ExportTabularENTM;

uses ExportCore,
     ExportTabularCore,
     ExportFlatList;


var ExportTabularENTM_outputLines: TStringList;


function initialize: Integer;
begin
    ExportTabularENTM_outputLines := TStringList.create();
    ExportTabularENTM_outputLines.add(
            '"File"'        // Name of the originating ESM
        + ', "Form ID"'     // Form ID
        + ', "Editor ID"'   // Editor ID
        + ', "Name (FULL)"' // Full name
        + ', "Name (NNAM)"' // Shortened name
        + ', "Description"' // Description
        + ', "Keywords"'    // Sorted JSON array of keywords. Each keyword is represented by its editor ID
    );
end;

function canProcess(e: IInterface): Boolean;
begin
    result := signature(e) = 'ENTM';
end;

function process(entm: IInterface): Integer;
begin
    if not canProcess(entm) then begin
        addMessage('Warning: ' + name(entm) + ' is not a ENTM. Entry was ignored.');
        exit;
    end;

    ExportTabularENTM_outputLines.add(
          escapeCsvString(getFileName(getFile(entm))) + ', '
        + escapeCsvString(stringFormID(entm)) + ', '
        + escapeCsvString(evBySign(entm, 'EDID')) + ', '
        + escapeCsvString(evBySign(entm, 'FULL')) + ', '
        + escapeCsvString(evBySign(entm, 'NNAM')) + ', '
        + escapeCsvString(evBySign(entm, 'DESC')) + ', '
        + escapeCsvString(getFlatKeywordList(entm))
    );
end;

function finalize: Integer;
begin
    createDir('dumps/');
    ExportTabularENTM_outputLines.saveToFile('dumps/ENTM.csv');
    ExportTabularENTM_outputLines.free();
end;


end.
