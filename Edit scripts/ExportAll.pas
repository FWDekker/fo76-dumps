(**
 * Exports (a selection of) all available dumps.
 *)
unit ExportAll;

uses ExportTabularALCH,
     ExportTabularARMO,
     ExportTabularCLAS,
     ExportTabularCOBJ,
     ExportTabularENTM,
     ExportTabularFACT,
     ExportTabularFLOR,
     ExportTabularGLOB,
     ExportTabularGMST,
     ExportTabularIDs,
     ExportTabularLVLI,
     ExportTabularMISC,
     ExportTabularNPC_,
     ExportTabularOMOD,
     ExportTabularOTFT,
     ExportTabularRACE,
     ExportTabularWEAP,
     ExportWikiBOOK,
     ExportWikiDIAL,
     ExportWikiNOTE,
     ExportWikiTERM;

var ExportAll_selection: TMemIniFile;



(**
 * Opens a prompt from which the user can select which dumps to include.
 *
 * @return the dumps selected by the user as an INI-like memory structure
 *)
function _selectDumps(): TMemIniFile;
var form: TForm;
    clb: TCheckListBox;

    i: Integer;
begin
    result := TMemIniFile.create('test.ini');

    form := frmFileSelect;
    try
        form.caption := 'Select dump scripts';

        clb := TCheckListBox(form.findComponent('CheckListBox1'));
        clb.items.add('IDs.csv');

        clb.items.add('ALCH.csv');
        clb.items.add('ARMO.csv');
        clb.items.add('CLAS.csv');
        clb.items.add('COBJ.csv');
        clb.items.add('ENTM.csv');
        clb.items.add('FACT.csv');
        clb.items.add('FLOR.csv');
        clb.items.add('GLOB.csv');
        clb.items.add('GMST.csv');
        clb.items.add('LVLI.csv');
        clb.items.add('MISC.csv');
        clb.items.add('NPC_.csv');
        clb.items.add('OMOD.csv');
        clb.items.add('OTFT.csv');
        clb.items.add('RACE.csv');
        clb.items.add('WEAP.csv');

        clb.items.add('BOOK.wiki');
        clb.items.add('DIAL.wiki');
        clb.items.add('NOTE.wiki');
        clb.items.add('TERM.wiki');

        // Show form
        if form.showModal() <> mrOk then begin exit; end;

        // Process selection
        for i := 0 to pred(clb.items.count) do begin
            result.writeBool('', clb.items[i], clb.checked[i]);
        end;
    finally
        form.free();
    end;
end;



function initialize(): Integer;
begin
    ExportAll_selection := _selectDumps();

    if ExportAll_selection.readBool('', 'IDs.csv', False) then begin ExportTabularIDs.initialize(); end;

    if ExportAll_selection.readBool('', 'ALCH.csv', False) then begin ExportTabularALCH.initialize(); end;
    if ExportAll_selection.readBool('', 'ARMO.csv', False) then begin ExportTabularARMO.initialize(); end;
    if ExportAll_selection.readBool('', 'CLAS.csv', False) then begin ExportTabularCLAS.initialize(); end;
    if ExportAll_selection.readBool('', 'COBJ.csv', False) then begin ExportTabularCOBJ.initialize(); end;
    if ExportAll_selection.readBool('', 'ENTM.csv', False) then begin ExportTabularENTM.initialize(); end;
    if ExportAll_selection.readBool('', 'FACT.csv', False) then begin ExportTabularFACT.initialize(); end;
    if ExportAll_selection.readBool('', 'FLOR.csv', False) then begin ExportTabularFLOR.initialize(); end;
    if ExportAll_selection.readBool('', 'GLOB.csv', False) then begin ExportTabularGLOB.initialize(); end;
    if ExportAll_selection.readBool('', 'GMST.csv', False) then begin ExportTabularGMST.initialize(); end;
    if ExportAll_selection.readBool('', 'LVLI.csv', False) then begin ExportTabularLVLI.initialize(); end;
    if ExportAll_selection.readBool('', 'MISC.csv', False) then begin ExportTabularMISC.initialize(); end;
    if ExportAll_selection.readBool('', 'NPC_.csv', False) then begin ExportTabularNPC_.initialize(); end;
    if ExportAll_selection.readBool('', 'OMOD.csv', False) then begin ExportTabularOMOD.initialize(); end;
    if ExportAll_selection.readBool('', 'OTFT.csv', False) then begin ExportTabularOTFT.initialize(); end;
    if ExportAll_selection.readBool('', 'RACE.csv', False) then begin ExportTabularRACE.initialize(); end;
    if ExportAll_selection.readBool('', 'WEAP.csv', False) then begin ExportTabularWEAP.initialize(); end;

    if ExportAll_selection.readBool('', 'BOOK.wiki', False) then begin ExportWikiBOOK.initialize(); end;
    if ExportAll_selection.readBool('', 'DIAL.wiki', False) then begin ExportWikiDIAL.initialize(); end;
    if ExportAll_selection.readBool('', 'NOTE.wiki', False) then begin ExportWikiNOTE.initialize(); end;
    if ExportAll_selection.readBool('', 'TERM.wiki', False) then begin ExportWikiTERM.initialize(); end;
end;

function process(el: IInterface): Integer;
var sig: String;
begin
    // `and` does not short-cut, so use nested `if`s instead

    sig := signature(el);
    if sig = 'PLYT' then begin exit; end;

    if ExportAll_selection.readBool('', 'IDs.csv', False) then begin ExportTabularIDs._process(el); end;

    if ExportAll_selection.readBool('', 'ALCH.csv', False) then begin if (sig = 'ALCH') then begin
        ExportTabularALCH._process(el);
    end else if ExportAll_selection.readBool('', 'ARMO.csv', False) then begin if (sig = 'ARMO') then begin
        ExportTabularARMO._process(el);
    end else if ExportAll_selection.readBool('', 'CLAS.csv', False) then begin if (sig = 'CLAS') then begin
        ExportTabularCLAS._process(el);
    end else if ExportAll_selection.readBool('', 'COBJ.csv', False) then begin if (sig = 'COBJ') then begin
        ExportTabularCOBJ._process(el);
    end else if ExportAll_selection.readBool('', 'ENTM.csv', False) then begin if (sig = 'ENTM') then begin
        ExportTabularENTM._process(el);
    end else if ExportAll_selection.readBool('', 'FACT.csv', False) then begin if (sig = 'FACT') then begin
        ExportTabularFACT._process(el);
    end else if ExportAll_selection.readBool('', 'FLOR.csv', False) then begin if (sig = 'FLOR') then begin
        ExportTabularFLOR._process(el);
    end else if ExportAll_selection.readBool('', 'GLOB.csv', False) then begin if (sig = 'GLOB') then begin
        ExportTabularGLOB._process(el);
    end else if ExportAll_selection.readBool('', 'GMST.csv', False) then begin if (sig = 'GMST') then begin
        ExportTabularGMST._process(el);
    end else if ExportAll_selection.readBool('', 'LVLI.csv', False) then begin if (sig = 'LVLI') then begin
        ExportTabularLVLI._process(el);
    end else if ExportAll_selection.readBool('', 'MISC.csv', False) then begin if (sig = 'MISC') then begin
        ExportTabularMISC._process(el);
    end else if ExportAll_selection.readBool('', 'NPC_.csv', False) then begin if (sig = 'NPC_') then begin
        ExportTabularNPC_._process(el);
    end else if ExportAll_selection.readBool('', 'OMOD.csv', False) then begin if (sig = 'OMOD') then begin
        ExportTabularOMOD._process(el);
    end else if ExportAll_selection.readBool('', 'OTFT.csv', False) then begin if (sig = 'OTFT') then begin
        ExportTabularOTFT._process(el);
    end else if ExportAll_selection.readBool('', 'RACE.csv', False) then begin if (sig = 'RACE') then begin
        ExportTabularRACE._process(el);
    end else if ExportAll_selection.readBool('', 'WEAP.csv', False) then begin if (sig = 'WEAP') then begin
        ExportTabularWEAP._process(el);
    end else if ExportAll_selection.readBool('', 'BOOK.wiki', False) then begin if (sig = 'BOOK') then begin
        ExportWikiBOOK._process(el);
    end else if ExportAll_selection.readBool('', 'DIAL.wiki', False) then begin if (sig = 'QUST') then begin
        ExportWikiDIAL._process(el);
    end else if ExportAll_selection.readBool('', 'NOTE.wiki', False) then begin if (sig = 'NOTE') then begin
        ExportWikiNOTE._process(el);
    end else if ExportAll_selection.readBool('', 'TERM.wiki', False) then begin if (sig = 'TERM') then begin
        ExportWikiTERM._process(el);
    end end end end end end end end end end end end end end end end end end end end end;
end;

function finalize(): Integer;
var ExportAll_outputLines: TStringList;
begin
    if ExportAll_selection.readBool('', 'IDs.csv', False) then begin ExportTabularIDs.finalize(); end;

    if ExportAll_selection.readBool('', 'ALCH.csv', False) then begin ExportTabularALCH.finalize(); end;
    if ExportAll_selection.readBool('', 'ARMO.csv', False) then begin ExportTabularARMO.finalize(); end;
    if ExportAll_selection.readBool('', 'CLAS.csv', False) then begin ExportTabularCLAS.finalize(); end;
    if ExportAll_selection.readBool('', 'COBJ.csv', False) then begin ExportTabularCOBJ.finalize(); end;
    if ExportAll_selection.readBool('', 'ENTM.csv', False) then begin ExportTabularENTM.finalize(); end;
    if ExportAll_selection.readBool('', 'FACT.csv', False) then begin ExportTabularFACT.finalize(); end;
    if ExportAll_selection.readBool('', 'FLOR.csv', False) then begin ExportTabularFLOR.finalize(); end;
    if ExportAll_selection.readBool('', 'GLOB.csv', False) then begin ExportTabularGLOB.finalize(); end;
    if ExportAll_selection.readBool('', 'GMST.csv', False) then begin ExportTabularGMST.finalize(); end;
    if ExportAll_selection.readBool('', 'LVLI.csv', False) then begin ExportTabularLVLI.finalize(); end;
    if ExportAll_selection.readBool('', 'MISC.csv', False) then begin ExportTabularMISC.finalize(); end;
    if ExportAll_selection.readBool('', 'NPC_.csv', False) then begin ExportTabularNPC_.finalize(); end;
    if ExportAll_selection.readBool('', 'OMOD.csv', False) then begin ExportTabularOMOD.finalize(); end;
    if ExportAll_selection.readBool('', 'OTFT.csv', False) then begin ExportTabularOTFT.finalize(); end;
    if ExportAll_selection.readBool('', 'RACE.csv', False) then begin ExportTabularRACE.finalize(); end;
    if ExportAll_selection.readBool('', 'WEAP.csv', False) then begin ExportTabularWEAP.finalize(); end;

    if ExportAll_selection.readBool('', 'BOOK.wiki', False) then begin ExportWikiBOOK.finalize(); end;
    if ExportAll_selection.readBool('', 'DIAL.wiki', False) then begin ExportWikiDIAL.finalize(); end;
    if ExportAll_selection.readBool('', 'NOTE.wiki', False) then begin ExportWikiNOTE.finalize(); end;
    if ExportAll_selection.readBool('', 'TERM.wiki', False) then begin ExportWikiTERM.finalize(); end;

    ExportAll_selection.free();

    createDir('dumps/');
    ExportAll_outputLines := TStringList.create();
    ExportAll_outputLines.add('All dumps completed. ' + errorStats(true));
    ExportAll_outputLines.saveToFile('dumps/_done.txt');
    ExportAll_outputLines.free();

    addMessage(errorStats(false));
    addMessage('Any errors and warnings have been written to `dumps/_done.txt`.');
end;


end.
