unit ExportTabularFLORA;

uses ExportCore,
     ExportTabularCore,
     ExportFlatList;


var ExportTabularFLORA_outputLines: TStringList;
var ExportTabularLOC_outputLines: TStringList;

function initialize: Integer;
begin
    ExportTabularFLORA_outputLines := TStringList.create();
    ExportTabularFLORA_outputLines.add(
            '"File"'                 // Name of the originating ESM
        + ', "Form ID"'              // Form ID
        + ', "Editor ID"'            // Editor ID
        + ', "Name"'                 // Full name
        + ', "Ingredient"'               // Item weight in pounds
        + ', "Keywords"'             // Sorted JSON array of keywords. Each keyword is represented by its editor ID
    );
    
    
    ExportTabularLOC_outputLines := initializeLocationTabular();
    
end;

function canProcess(e: IInterface): Boolean;
begin
    result := signature(e) = 'FLOR';
end;

function process(flora: IInterface): Integer;
var data: IInterface;
begin
    if not canProcess(flora) then begin
        addMessage('Warning: ' + name(flora) + ' is not a FLORA. Entry was ignored.');
        exit;
    end;

    data := eBySign(flora, 'DATA');

    ExportTabularFLORA_outputLines.add(
          escapeCsvString(getFileName(getFile(flora))) + ', '
        + escapeCsvString(stringFormID(flora)) + ', '
        + escapeCsvString(evBySign(flora, 'EDID')) + ', '
        + escapeCsvString(evBySign(flora, 'FULL')) + ', '
        + escapeCsvString(evByName(flora, 'PFIG')) + ', '
        + escapeCsvString(getFlatKeywordList(flora))
    );
    
    ExportTabularLOC_outputLines.AddStrings(
        getLocationData(flora)
    );
    
end;



function finalize: Integer;
begin
    createDir('dumps/');
    ExportTabularFLORA_outputLines.saveToFile('dumps/FLORA.csv');
    ExportTabularLOC_outputLines.saveToFile('dumps/FLORALOC.csv');
    ExportTabularLOC_outputLines.free();
    ExportTabularFLORA_outputLines.free();
end;


end.
