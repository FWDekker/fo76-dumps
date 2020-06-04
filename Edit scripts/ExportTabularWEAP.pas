unit ExportTabularWEAP;

uses ExportCore,
     ExportTabularCore,
     ExportFlatList;


var ExportTabularWEAP_outputLines: TStringList;
var ExportTabularLOC_outputLines: TStringList;

function initialize: Integer;
begin
    ExportTabularWEAP_outputLines := TStringList.create();
    ExportTabularWEAP_outputLines.add(
            '"File"'                 // Name of the originating ESM
        + ', "Form ID"'              // Form ID
        + ', "Editor ID"'            // Editor ID
        + ', "Name"'                 // Full name
        + ', "Weight"'               // Item weight in pounds
        + ', "Value"'                // Item value in bottlecaps
        + ', "Health"'               // Item health in points
        + ', "Race"'                 // The race that can wear this weapr
        + ', "Levels"'               // Sorted JSON array of possible weapr levels
        + ', "DR curve"'             // Damage Resistance curve
        + ', "Durability min curve"' // Min durability curve
        + ', "Durability max curve"' // Max durability curve
        + ', "Condition dmg curve"'  // Condition damage scale factor curve
        + ', "Attach slots"'         // Sorted JSON array of attachment slots available to the weapr
        + ', "Equip slots"'          // Sorted JSON array of equipment slots used by the weapr
        + ', "Keywords"'             // Sorted JSON array of keywords. Each keyword is represented by its editor ID
    );
	
	
	ExportTabularLOC_outputLines := initializeLocationTabular();
	
end;

function canProcess(e: IInterface): Boolean;
begin
    result := signature(e) = 'WEAP';
end;

function process(weap: IInterface): Integer;
var data: IInterface;
begin
    if not canProcess(weap) then begin
        addMessage('Warning: ' + name(weap) + ' is not a WEAP. Entry was ignored.');
        exit;
    end;

    data := eBySign(weap, 'DATA');

    ExportTabularWEAP_outputLines.add(
		  escapeCsvString(getFileName(getFile(weap))) + ', '
        + escapeCsvString(stringFormID(weap)) + ', '
        + escapeCsvString(evBySign(weap, 'EDID')) + ', '
        + escapeCsvString(evBySign(weap, 'FULL')) + ', '
        + escapeCsvString(evByName(data, 'Weight')) + ', '
		+ escapeCsvString(evByName(data, 'Value')) + ', '
        + escapeCsvString(evByName(data, 'Health')) + ', '
        + escapeCsvString(evBySign(weap, 'RNAM')) + ', '
        + escapeCsvString(getFlatChildList(eBySign(weap, 'EILV'))) + ','
        + escapeCsvString(evBySign(weap, 'CVT0')) + ','
        + escapeCsvString(evBySign(weap, 'CVT1')) + ','
        + escapeCsvString(evBySign(weap, 'CVT3')) + ','
        + escapeCsvString(evBySign(weap, 'CVT2')) + ','
        + escapeCsvString(getFlatChildList(eBySign(weap, 'APPR'))) + ','
        + escapeCsvString(getFlatChildNameList(eByIndex(eBySign(weap, 'BOD2'), 0))) + ', '
        + escapeCsvString(getFlatKeywordList(weap))
    );
	
	ExportTabularLOC_outputLines.AddStrings(
		getLocationData(weap)
	);
	
end;



function finalize: Integer;
begin
    createDir('dumps/');
    ExportTabularWEAP_outputLines.saveToFile('dumps/WEAP.csv');
	ExportTabularLOC_outputLines.saveToFile('dumps/WEAPLOC.csv');
	ExportTabularLOC_outputLines.free();
    ExportTabularWEAP_outputLines.free();
end;


end.
