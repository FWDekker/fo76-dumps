unit ExportTabularENTM;

uses ExportCore,
     ExportTabularCore;


var ExportTabularENTM_outputLines: TStringList;


function initialize: Integer;
begin
    ExportTabularENTM_outputLines := TStringList.create();
    ExportTabularENTM_outputLines.add('"File", "Form ID", "Editor ID", "Name (FULL)", "Name (NNAM)", "Keywords"');
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
