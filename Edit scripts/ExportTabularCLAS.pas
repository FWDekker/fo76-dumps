unit ExportTabularCLAS;

uses ExportCore,
     ExportTabularCore;


var ExportTabularCLAS_outputLines: TStringList;


function initialize: Integer;
begin
    ExportTabularCLAS_outputLines := TStringList.create;
    ExportTabularCLAS_outputLines.add('"File", "Form ID", "Editor ID", "Name", "Properties"');
end;

function canProcess(e: IInterface): Boolean;
begin
    result := signature(e) = 'CLAS';
end;

function process(clas: IInterface): Integer;
var acbs: IInterface;
    rnam: IInterface;
    aidt: IInterface;
    cnam: IInterface;
begin
    if not canProcess(clas) then begin
        addMessage('Warning: ' + name(clas) + ' is not a CLAS. Entry was ignored.');
        exit;
    end;

    acbs := eBySignature(clas, 'ACBS');
    rnam := linksTo(eBySignature(clas, 'RNAM'));
    aidt := eBySignature(clas, 'AIDT');
    cnam := linksTo(eBySignature(clas, 'CNAM'));

    ExportTabularCLAS_outputLines.add(
        escapeCsvString(getFileName(getFile(clas))) + ', ' +
        escapeCsvString(stringFormID(clas)) + ', ' +
        escapeCsvString(evBySignature(clas, 'EDID')) + ', ' +
        escapeCsvString(evBySignature(clas, 'FULL')) + ', ' +
        escapeCsvString(getFlatPropertyList(clas))
    );
end;

function finalize: Integer;
begin
    createDir('dumps/');
    ExportTabularCLAS_outputLines.saveToFile('dumps/CLAS.csv');
end;


end.
