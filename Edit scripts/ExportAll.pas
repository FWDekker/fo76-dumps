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
        clb.items.add('ALCH.csv');
        clb.items.add('ARMO.csv');
        clb.items.add('CLAS.csv');
        clb.items.add('COBJ.csv');
        clb.items.add('ENTM.csv');
        clb.items.add('FACT.csv');
        clb.items.add('FLOR.csv');
        clb.items.add('GLOB.csv');
        clb.items.add('GMST.csv');
        clb.items.add('IDs.csv');
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
        if form.showModal() <> mrOk then begin
            exit;
        end;

        // Process selection
        for i := 0 to pred(clb.items.count) do begin
            result.writeBool('', clb.items[i], clb.checked[i]);
        end;
    finally
        form.free();
    end;
end;

(**
 * Returns `True` if and only if the dump identified by [name] has been selected for dumping.
 *)
function _selected(name: String): Boolean;
begin
    result := ExportAll_selection.readBool('', name, False);
end;



function initialize(): Integer;
begin
    ExportAll_selection := _selectDumps();

    if _selected('ALCH.csv') then begin ExportTabularALCH.initialize(); end;
    if _selected('ARMO.csv') then begin ExportTabularARMO.initialize(); end;
    if _selected('CLAS.csv') then begin ExportTabularCLAS.initialize(); end;
    if _selected('COBJ.csv') then begin ExportTabularCOBJ.initialize(); end;
    if _selected('ENTM.csv') then begin ExportTabularENTM.initialize(); end;
    if _selected('FACT.csv') then begin ExportTabularFACT.initialize(); end;
    if _selected('FLOR.csv') then begin ExportTabularFLOR.initialize(); end;
    if _selected('GLOB.csv') then begin ExportTabularGLOB.initialize(); end;
    if _selected('GMST.csv') then begin ExportTabularGMST.initialize(); end;
    if _selected('IDs.csv') then begin ExportTabularIDs.initialize(); end;
    if _selected('LVLI.csv') then begin ExportTabularLVLI.initialize(); end;
    if _selected('MISC.csv') then begin ExportTabularMISC.initialize(); end;
    if _selected('NPC_.csv') then begin ExportTabularNPC_.initialize(); end;
    if _selected('OMOD.csv') then begin ExportTabularOMOD.initialize(); end;
    if _selected('OTFT.csv') then begin ExportTabularOTFT.initialize(); end;
    if _selected('RACE.csv') then begin ExportTabularRACE.initialize(); end;
    if _selected('WEAP.csv') then begin ExportTabularWEAP.initialize(); end;
    if _selected('BOOK.wiki') then begin ExportWikiBOOK.initialize(); end;
    if _selected('DIAL.wiki') then begin ExportWikiDIAL.initialize(); end;
    if _selected('NOTE.wiki') then begin ExportWikiNOTE.initialize(); end;
    if _selected('TERM.wiki') then begin ExportWikiTERM.initialize(); end;
end;

function process(el: IInterface): Integer;
begin
    if signature(el) = 'PLYT' then begin exit; end;

    if _selected('ALCH.csv') then begin ExportTabularALCH.process(el); end;
    if _selected('ARMO.csv') then begin ExportTabularARMO.process(el); end;
    if _selected('CLAS.csv') then begin ExportTabularCLAS.process(el); end;
    if _selected('COBJ.csv') then begin ExportTabularCOBJ.process(el); end;
    if _selected('ENTM.csv') then begin ExportTabularENTM.process(el); end;
    if _selected('FACT.csv') then begin ExportTabularFACT.process(el); end;
    if _selected('FLOR.csv') then begin ExportTabularFLOR.process(el); end;
    if _selected('GLOB.csv') then begin ExportTabularGLOB.process(el); end;
    if _selected('GMST.csv') then begin ExportTabularGMST.process(el); end;
    if _selected('IDs.csv') then begin ExportTabularIDs.process(el); end;
    if _selected('LVLI.csv') then begin ExportTabularLVLI.process(el); end;
    if _selected('MISC.csv') then begin ExportTabularMISC.process(el); end;
    if _selected('NPC_.csv') then begin ExportTabularNPC_.process(el); end;
    if _selected('OMOD.csv') then begin ExportTabularOMOD.process(el); end;
    if _selected('OTFT.csv') then begin ExportTabularOTFT.process(el); end;
    if _selected('RACE.csv') then begin ExportTabularRACE.process(el); end;
    if _selected('WEAP.csv') then begin ExportTabularWEAP.process(el); end;
    if _selected('BOOK.wiki') then begin ExportWikiBOOK.process(el); end;
    if _selected('DIAL.wiki') then begin ExportWikiDIAL.process(el); end;
    if _selected('NOTE.wiki') then begin ExportWikiNOTE.process(el); end;
    if _selected('TERM.wiki') then begin ExportWikiTERM.process(el); end;
end;

function finalize(): Integer;
var ExportAll_outputLines: TStringList;
begin
    if _selected('ALCH.csv') then begin ExportTabularALCH.finalize(); end;
    if _selected('ARMO.csv') then begin ExportTabularARMO.finalize(); end;
    if _selected('CLAS.csv') then begin ExportTabularCLAS.finalize(); end;
    if _selected('COBJ.csv') then begin ExportTabularCOBJ.finalize(); end;
    if _selected('ENTM.csv') then begin ExportTabularENTM.finalize(); end;
    if _selected('FACT.csv') then begin ExportTabularFACT.finalize(); end;
    if _selected('FLOR.csv') then begin ExportTabularFLOR.finalize(); end;
    if _selected('GLOB.csv') then begin ExportTabularGLOB.finalize(); end;
    if _selected('GMST.csv') then begin ExportTabularGMST.finalize(); end;
    if _selected('IDs.csv') then begin ExportTabularIDs.finalize(); end;
    if _selected('LVLI.csv') then begin ExportTabularLVLI.finalize(); end;
    if _selected('MISC.csv') then begin ExportTabularMISC.finalize(); end;
    if _selected('NPC_.csv') then begin ExportTabularNPC_.finalize(); end;
    if _selected('OMOD.csv') then begin ExportTabularOMOD.finalize(); end;
    if _selected('OTFT.csv') then begin ExportTabularOTFT.finalize(); end;
    if _selected('RACE.csv') then begin ExportTabularRACE.finalize(); end;
    if _selected('WEAP.csv') then begin ExportTabularWEAP.finalize(); end;
    if _selected('BOOK.wiki') then begin ExportWikiBOOK.finalize(); end;
    if _selected('DIAL.wiki') then begin ExportWikiDIAL.finalize(); end;
    if _selected('NOTE.wiki') then begin ExportWikiNOTE.finalize(); end;
    if _selected('TERM.wiki') then begin ExportWikiTERM.finalize(); end;

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
