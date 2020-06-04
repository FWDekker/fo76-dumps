unit ExportTabularARMO;

uses ExportCore,
     ExportTabularCore,
     ExportFlatList;


var ExportTabularARMO_outputLines: TStringList;
var ExportTabularLOC_outputLines: TStringList;

function initialize: Integer;
begin
    ExportTabularARMO_outputLines := TStringList.create();
    ExportTabularARMO_outputLines.add(
            '"File"'                 // Name of the originating ESM
        + ', "Form ID"'              // Form ID
        + ', "Editor ID"'            // Editor ID
        + ', "Name"'                 // Full name
        + ', "Weight"'               // Item weight in pounds
        + ', "Value"'                // Item value in bottlecaps
        + ', "Health"'               // Item health in points
        + ', "Race"'                 // The race that can wear this armor
        + ', "Levels"'               // Sorted JSON array of possible armor levels
        + ', "DR curve"'             // Damage Resistance curve
        + ', "Durability min curve"' // Min durability curve
        + ', "Durability max curve"' // Max durability curve
        + ', "Condition dmg curve"'  // Condition damage scale factor curve
        + ', "Attach slots"'         // Sorted JSON array of attachment slots available to the armor
        + ', "Equip slots"'          // Sorted JSON array of equipment slots used by the armor
        + ', "Keywords"'             // Sorted JSON array of keywords. Each keyword is represented by its editor ID
    );
	
	
	ExportTabularLOC_outputLines := initializeLocationTabular();
	
end;

function canProcess(e: IInterface): Boolean;
begin
    result := signature(e) = 'ARMO';
end;

function process(armo: IInterface): Integer;
var data: IInterface;
begin
    if not canProcess(armo) then begin
        addMessage('Warning: ' + name(armo) + ' is not a ARMO. Entry was ignored.');
        exit;
    end;

    data := eBySign(armo, 'DATA');

    ExportTabularARMO_outputLines.add(
		  escapeCsvString(getFileName(getFile(armo))) + ', '
        + escapeCsvString(stringFormID(armo)) + ', '
        + escapeCsvString(evBySign(armo, 'EDID')) + ', '
        + escapeCsvString(evBySign(armo, 'FULL')) + ', '
        + escapeCsvString(evByName(data, 'Weight')) + ', '
		+ escapeCsvString(evByName(data, 'Value')) + ', '
        + escapeCsvString(evByName(data, 'Health')) + ', '
        + escapeCsvString(evBySign(armo, 'RNAM')) + ', '
        + escapeCsvString(getFlatChildList(eBySign(armo, 'EILV'))) + ','
        + escapeCsvString(evBySign(armo, 'CVT0')) + ','
        + escapeCsvString(evBySign(armo, 'CVT1')) + ','
        + escapeCsvString(evBySign(armo, 'CVT3')) + ','
        + escapeCsvString(evBySign(armo, 'CVT2')) + ','
        + escapeCsvString(getFlatChildList(eBySign(armo, 'APPR'))) + ','
        + escapeCsvString(getFlatChildNameList(eByIndex(eBySign(armo, 'BOD2'), 0))) + ', '
        + escapeCsvString(getFlatKeywordList(armo))
    );
	
	ExportTabularLOC_outputLines.AddStrings(
		getLocationData(armo)
	);
	
end;



function finalize: Integer;
begin
    createDir('dumps/');
    ExportTabularARMO_outputLines.saveToFile('dumps/ARMO.csv');
	ExportTabularLOC_outputLines.saveToFile('dumps/ARMOLOC.csv');
	ExportTabularLOC_outputLines.free();
    ExportTabularARMO_outputLines.free();
end;


end.
