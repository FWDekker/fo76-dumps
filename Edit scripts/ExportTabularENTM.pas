unit ExportTabularENTM;

uses ExportCore,
     ExportTabularCore;


var outputLines: TStringList;


function initialize: Integer;
begin
    outputLines := TStringList.create;
    outputLines.add('"File", "Form ID", "Editor ID", "Name (FULL)", "Name (NNAM)", "Keywords"');
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

    outputLines.add(
        escapeCsvString(getFileName(getFile(entm))) + ', ' +
        escapeCsvString(stringFormID(entm)) + ', ' +
        escapeCsvString(evBySignature(entm, 'EDID')) + ', ' +
        escapeCsvString(evBySignature(entm, 'FULL')) + ', ' +
        escapeCsvString(evBySignature(entm, 'NNAM')) + ', ' +
        escapeCsvString(getFlatKeywordList(entm))
    );
end;

function finalize: Integer;
begin
    createDir('dumps/');
    outputLines.saveToFile('dumps/ENTM.csv');
end;


end.
