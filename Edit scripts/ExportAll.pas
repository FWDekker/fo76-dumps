(**
 * Exports (a selection of) all available dumps.
 *)
unit ExportAll;

uses ExportTabularARMO,
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

var ExportAll_selection: String;



(**
 * Opens a prompt from which the user can select which dumps to include.
 *
 * @return the dumps selected by the user
 *)
function _selectDumps(): TStringList;
var form: TForm;
    clb: TCheckListBox;

    i: Integer;
begin
    result := TStringList.create();

    form := frmFileSelect;
    try
        form.caption := 'Select dump scripts';

        clb := TCheckListBox(form.findComponent('CheckListBox1'));
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

        // Process input
        for i := 0 to pred(clb.items.count) do begin
            if clb.checked[i] then begin
                result.add(clb.items[i]);
            end;
        end;
    finally
        form.free();
    end;
end;

(**
 * Returns `true` if the user has selected the given dump to be performed.
 *
 * @return `true` if the user has selected the given dump to be performed
 *)
function _hasSelectedDump(dump: String): Boolean;
begin
    result := pos(dump, ExportAll_selection) <> 0;
end;



function initialize(): Integer;
begin
    ExportAll_selection := _selectDumps().text;
    if ExportAll_selection = '' then begin
        result := 1;
        exit;
    end;

    if _hasSelectedDump('ARMO.csv') then begin
        ExportTabularARMO.initialize();
    end;
    if _hasSelectedDump('CLAS.csv') then begin
        ExportTabularCLAS.initialize();
    end;
    if _hasSelectedDump('COBJ.csv') then begin
        ExportTabularCOBJ.initialize();
    end;
    if _hasSelectedDump('ENTM.csv') then begin
        ExportTabularENTM.initialize();
    end;
    if _hasSelectedDump('FACT.csv') then begin
        ExportTabularFACT.initialize();
    end;
    if _hasSelectedDump('FLOR.csv') then begin
        ExportTabularFLOR.initialize();
    end;
    if _hasSelectedDump('GLOB.csv') then begin
        ExportTabularGLOB.initialize();
    end;
    if _hasSelectedDump('GMST.csv') then begin
        ExportTabularGMST.initialize();
    end;
    if _hasSelectedDump('IDs.csv') then begin
        ExportTabularIDs.initialize();
    end;
    if _hasSelectedDump('LVLI.csv') then begin
        ExportTabularLVLI.initialize();
    end;
    if _hasSelectedDump('MISC.csv') then begin
        ExportTabularMISC.initialize();
    end;
    if _hasSelectedDump('NPC_.csv') then begin
        ExportTabularNPC_.initialize();
    end;
    if _hasSelectedDump('OMOD.csv') then begin
        ExportTabularOMOD.initialize();
    end;
    if _hasSelectedDump('OTFT.csv') then begin
        ExportTabularOTFT.initialize();
    end;
    if _hasSelectedDump('RACE.csv') then begin
        ExportTabularRACE.initialize();
    end;
    if _hasSelectedDump('WEAP.csv') then begin
        ExportTabularWEAP.initialize();
    end;
    if _hasSelectedDump('BOOK.wiki') then begin
        ExportWikiBOOK.initialize();
    end;
    if _hasSelectedDump('DIAL.wiki') then begin
        ExportWikiDIAL.initialize();
    end;
    if _hasSelectedDump('NOTE.wiki') then begin
        ExportWikiNOTE.initialize();
    end;
    if _hasSelectedDump('TERM.wiki') then begin
        ExportWikiTERM.initialize();
    end;
end;

function process(el: IInterface): Integer;
begin
    if _hasSelectedDump('ARMO.csv') and ExportTabularARMO.canProcess(el) then begin
        ExportTabularARMO.process(el);
    end;
    if _hasSelectedDump('CLAS.csv') and ExportTabularCLAS.canProcess(el) then begin
        ExportTabularCLAS.process(el);
    end;
    if _hasSelectedDump('COBJ.csv') and ExportTabularCOBJ.canProcess(el) then begin
        ExportTabularCOBJ.process(el);
    end;
    if _hasSelectedDump('ENTM.csv') and ExportTabularENTM.canProcess(el) then begin
        ExportTabularENTM.process(el);
    end;
    if _hasSelectedDump('FACT.csv') and ExportTabularFACT.canProcess(el) then begin
        ExportTabularFACT.process(el);
    end;
    if _hasSelectedDump('FLOR.csv') and ExportTabularFLOR.canProcess(el) then begin
        ExportTabularFLOR.process(el);
    end;
    if _hasSelectedDump('GLOB.csv') and ExportTabularGLOB.canProcess(el) then begin
        ExportTabularGLOB.process(el);
    end;
    if _hasSelectedDump('GMST.csv') and ExportTabularGMST.canProcess(el) then begin
        ExportTabularGMST.process(el);
    end;
    if _hasSelectedDump('IDs.csv') and ExportTabularIDs.canProcess(el) then begin
        ExportTabularIDs.process(el);
    end;
    if _hasSelectedDump('LVLI.csv') and ExportTabularLVLI.canProcess(el) then begin
        ExportTabularLVLI.process(el);
    end;
    if _hasSelectedDump('MISC.csv') and ExportTabularMISC.canProcess(el) then begin
        ExportTabularMISC.process(el);
    end;
    if _hasSelectedDump('NPC_.csv') and ExportTabularNPC_.canProcess(el) then begin
        ExportTabularNPC_.process(el);
    end;
    if _hasSelectedDump('OMOD.csv') and ExportTabularOMOD.canProcess(el) then begin
        ExportTabularOMOD.process(el);
    end;
    if _hasSelectedDump('OTFT.csv') and ExportTabularOTFT.canProcess(el) then begin
        ExportTabularOTFT.process(el);
    end;
    if _hasSelectedDump('RACE.csv') and ExportTabularRACE.canProcess(el) then begin
        ExportTabularRACE.process(el);
    end;
    if _hasSelectedDump('WEAP.csv') and ExportTabularWEAP.canProcess(el) then begin
        ExportTabularWEAP.process(el);
    end;
    if _hasSelectedDump('BOOK.wiki') and ExportWikiBOOK.canProcess(el) then begin
        ExportWikiBOOK.process(el);
    end;
    if _hasSelectedDump('DIAL.wiki') and ExportWikiDIAL.canProcess(el) then begin
        ExportWikiDIAL.process(el);
    end;
    if _hasSelectedDump('NOTE.wiki') and ExportWikiNOTE.canProcess(el) then begin
        ExportWikiNOTE.process(el);
    end;
    if _hasSelectedDump('TERM.wiki') and ExportWikiTERM.canProcess(el) then begin
        ExportWikiTERM.process(el);
    end;
end;

function finalize(): Integer;
var ExportAll_outputLines: TStringList;
begin
    if _hasSelectedDump('ARMO.csv') then begin
        ExportTabularARMO.finalize();
    end;
    if _hasSelectedDump('CLAS.csv') then begin
        ExportTabularCLAS.finalize();
    end;
    if _hasSelectedDump('COBJ.csv') then begin
        ExportTabularCOBJ.finalize();
    end;
    if _hasSelectedDump('ENTM.csv') then begin
        ExportTabularENTM.finalize();
    end;
    if _hasSelectedDump('FACT.csv') then begin
        ExportTabularFACT.finalize();
    end;
    if _hasSelectedDump('FLOR.csv') then begin
        ExportTabularFLOR.finalize();
    end;
    if _hasSelectedDump('GLOB.csv') then begin
        ExportTabularGLOB.finalize();
    end;
    if _hasSelectedDump('GMST.csv') then begin
        ExportTabularGMST.finalize();
    end;
    if _hasSelectedDump('IDs.csv') then begin
        ExportTabularIDs.finalize();
    end;
    if _hasSelectedDump('LVLI.csv') then begin
        ExportTabularLVLI.finalize();
    end;
    if _hasSelectedDump('MISC.csv') then begin
        ExportTabularMISC.finalize();
    end;
    if _hasSelectedDump('NPC_.csv') then begin
        ExportTabularNPC_.finalize();
    end;
    if _hasSelectedDump('OMOD.csv') then begin
        ExportTabularOMOD.finalize();
    end;
    if _hasSelectedDump('OTFT.csv') then begin
        ExportTabularOTFT.finalize();
    end;
    if _hasSelectedDump('RACE.csv') then begin
        ExportTabularRACE.finalize();
    end;
    if _hasSelectedDump('WEAP.csv') then begin
        ExportTabularWEAP.finalize();
    end;
    if _hasSelectedDump('BOOK.wiki') then begin
        ExportWikiBOOK.finalize();
    end;
    if _hasSelectedDump('DIAL.wiki') then begin
        ExportWikiDIAL.finalize();
    end;
    if _hasSelectedDump('NOTE.wiki') then begin
        ExportWikiNOTE.finalize();
    end;
    if _hasSelectedDump('TERM.wiki') then begin
        ExportWikiTERM.finalize();
    end;

    createDir('dumps/');
    ExportAll_outputLines := TStringList.create();
    ExportAll_outputLines.add('All dumps completed. ' + errorStats(true));
    ExportAll_outputLines.saveToFile('dumps/_done.txt');
    ExportAll_outputLines.free();

    addMessage(errorStats(false));
    addMessage('Any errors and warnings have been written to `dumps/_done.txt`.');
end;


end.
