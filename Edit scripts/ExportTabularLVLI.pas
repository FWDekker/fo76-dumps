unit ExportTabularLVLI;

uses ExportCore,
     ExportTabularCore,
     ExportFlatList;


var ExportTabularLVLI_outputLines: TStringList;
var ExportTabularLOC_outputLines: TStringList;

function initialize: Integer;
begin
    ExportTabularLVLI_outputLines := TStringList.create();
    ExportTabularLVLI_outputLines.add(
            '"File"'                 // Name of the originating ESM
        + ', "Form ID"'              // Form ID
        + ', "Editor ID"'            // Editor ID
        + ', "Name"'                 // Full name
        + ', "Leveled List"'         // Leveled list
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
        addMessage('Warning: ' + name(lvli) + ' is not a LVLI. Entry was ignored.');
        exit;
    end;

    data := eBySign(lvli, 'DATA');
	//debugPrint(evBySign(lvli, 'LVLF'));
	//debugPrint(evByName(lvli, 'Leveled List Entries'));
    ExportTabularLVLI_outputLines.add(
		  escapeCsvString(getFileName(getFile(lvli))) + ', '
        + escapeCsvString(stringFormID(lvli)) + ', '
        + escapeCsvString(evBySign(lvli, 'EDID')) + ', '
        + escapeCsvString(evBySign(lvli, 'FULL')) + ', '
		//https://github.com/fireundubh/xedit-scripts/blob/master/all/Relevel%20Leveled%20Lists.pas
		+ escapeCsvString(getFlatLeveledList(lvli))
   
    );
	
	ExportTabularLOC_outputLines.AddStrings(
		getLocationData(lvli)
	);
	
end;



function finalize: Integer;
begin
    createDir('dumps/');
    ExportTabularLVLI_outputLines.saveToFile('dumps/LVLI.csv');
	ExportTabularLOC_outputLines.saveToFile('dumps/LVLILOC.csv');
	ExportTabularLOC_outputLines.free();
    ExportTabularLVLI_outputLines.free();
end;


end.
