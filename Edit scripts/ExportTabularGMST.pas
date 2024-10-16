unit ExportTabularGMST;

uses ExportCore,
     ExportTabularCore;


var ExportTabularGMST_outputLines: TStringList;


function initialize(): Integer;
begin
    ExportTabularGMST_outputLines := TStringList.create();
    ExportTabularGMST_outputLines.add(
        '"File", ' +       // Name of the originating ESM
        '"Form ID", ' +    // Form ID
        '"Editor ID", ' +  // Editor ID
        '"Type", ' +       // Type of value, such as `string` or `float`
        '"Value"'          // Value of the settings
    );
end;

function process(el: IInterface): Integer;
begin
    if signature(el) <> 'GMST' then begin exit; end;

    _process(el);
end;

function _process(gmst: IInterface): Integer;
begin
    ExportTabularGMST_outputLines.add(
        escapeCsvString(getFileName(getFile(gmst))) + ', ' +
        escapeCsvString(stringFormID(gmst)) + ', ' +
        escapeCsvString(getEditValue(elementBySignature(gmst, 'EDID'))) + ', ' +
        escapeCsvString(letterToType(copy(getEditValue(elementBySignature(gmst, 'EDID')), 1, 1))) + ', ' +
        escapeCsvString(getEditValue(lastElement(elementBySignature(gmst, 'DATA'))))
    );
end;

function finalize(): Integer;
begin
    createDir('dumps/');
    ExportTabularGMST_outputLines.saveToFile('dumps/GMST.csv');
    ExportTabularGMST_outputLines.free();
end;


function letterToType(letter: String): String;
begin
    if letter = 'b' then begin
        result := 'boolean';
    end else if letter = 'f' then begin
        result := 'float';
    end else if letter = 'i' then begin
        result := 'integer';
    end else if letter = 's' then begin
        result := 'string';
    end else if letter = 'u' then begin
        result := 'unsigned integer';
    end else begin
        result := addError('Unknown type `' + letter + '`');
    end;
end;


end.
