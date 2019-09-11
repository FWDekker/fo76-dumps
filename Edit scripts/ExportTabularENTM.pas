unit ExportTabularENTM;

uses ExportCore,
     ExportTabularCore;


var outputLines: TStringList;


function initialize: Integer;
begin
    outputLines := TStringList.create;
    outputLines.add('"File", "Form ID", "Editor ID", "Name (FULL)", "Name (NNAM)", "Keywords"');
end;

function process(e: IInterface): Integer;
begin
    if signature(e) <> 'ENTM' then begin
        addMessage('Warning: ' + name(e) + ' is not a ENTM. Entry was ignored.');
        exit;
    end;

    outputLines.add(
        escapeCsvString(getFileName(getFile(e))) + ', ' +
        escapeCsvString(stringFormID(e)) + ', ' +
        escapeCsvString(evBySignature(e, 'EDID')) + ', ' +
        escapeCsvString(evBySignature(e, 'FULL')) + ', ' +
        escapeCsvString(evBySignature(e, 'NNAM')) + ', ' +
        escapeCsvString(getFlatKeywordList(e))
    );
end;

function finalize: Integer;
begin
    createDir('dumps/');
    outputLines.saveToFile('dumps/ENTM.csv');
end;


end.
