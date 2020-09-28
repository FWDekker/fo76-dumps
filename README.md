# Fallout 76 data dumps
[![Latest release version](https://img.shields.io/github/release/FWDekker/fo76-dumps?style=for-the-badge)](https://github.com/FWDekker/fo76-dumps/releases/latest)

This repository contains a number of data dumps of _Fallout 76_ in several formats.

## Files
The dumps are distributed as attachments to [this repository's releases](https://github.com/FWDekker/fo76-dumps/releases).

### Tabular
Tabular dumps are a simplified sort of dump that contains only the most important information.
These records should be very easy to understand by anyone.
For more information on how to browse them, check [the wiki page](https://github.com/FWDekker/fo76-dumps/wiki/Browsing-CSV-files).

Some dumps also have associated `_LOC` dumps, which contain information on the in-game locations of the records of that type.
To manually interpret location data, take a look at my [maps with grids](https://fallout.fandom.com/wiki/User_blog:FDekker/Maps_with_grids) resources.

<details>
  <summary>Click here for a list of tabular dumps</summary>
  <p>

| Dump script                                                     | Filename   | Description                                      |
|-----------------------------------------------------------------|------------|--------------------------------------------------|
| [`ExportTabularIDs.pas`](Edit%20scripts/ExportTabularIDs.pas)   | `IDs.csv`  | Form IDs, editor IDs, names, and keywords        |
| [`ExportTabularARMO.pas`](Edit%20scripts/ExportTabularARMO.pas) | `ARMO.csv` | Armor and clothing                               |
| [`ExportTabularCLAS.pas`](Edit%20scripts/ExportTabularCLAS.pas) | `CLAS.csv` | Class properties                                 |
| [`ExportTabularCOBJ.pas`](Edit%20scripts/ExportTabularCOBJ.pas) | `COBJ.csv` | Craftable object recipes and components          |
| [`ExportTabularENTM.pas`](Edit%20scripts/ExportTabularENTM.pas) | `ENTM.csv` | Atomic Shop unlockables                          |
| [`ExportTabularFACT.pas`](Edit%20scripts/ExportTabularFACT.pas) | `FACT.csv` | Factions and vendors                             |
| [`ExportTabularFLOR.pas`](Edit%20scripts/ExportTabularFLOR.pas) | `FLOR.csv` | Harvestable plants                               |
| [`ExportTabularGLOB.pas`](Edit%20scripts/ExportTabularGLOB.pas) | `GLOB.csv` | Global variables                                 |
| [`ExportTabularGMST.pas`](Edit%20scripts/ExportTabularGMST.pas) | `GMST.csv` | Game settings                                    |
| [`ExportTabularLVLI.pas`](Edit%20scripts/ExportTabularLVLI.pas) | `LVLI.csv` | Leveled lists                                    |
| [`ExportTabularMISC.pas`](Edit%20scripts/ExportTabularMISC.pas) | `MISC.csv` | Inventory item weights, values, and scrap yields |
| [`ExportTabularNPC_.pas`](Edit%20scripts/ExportTabularNPC_.pas) | `NPC_.csv` | NPC factions, keywords, stats, etc.              |
| [`ExportTabularOMOD.pas`](Edit%20scripts/ExportTabularOMOD.pas) | `OMOD.csv` | Armor and weapon mods                            |
| [`ExportTabularOTFT.pas`](Edit%20scripts/ExportTabularOTFT.pas) | `OTFT.csv` | Outfits                                          |
| [`ExportTabularRACE.pas`](Edit%20scripts/ExportTabularRACE.pas) | `RACE.csv` | Race keywords and properties                     |
| [`ExportTabularWEAP.pas`](Edit%20scripts/ExportTabularWEAP.pas) | `WEAP.csv` | Weapons                                          |

  </p>
</details>

### Wiki
Wiki dumps are generated for the [Fallout Wiki](https://fallout.fandom.com/) and use [MediaWiki](https://www.mediawiki.org) templates.
These dumps are useful when editing the wiki.
Even though the extension is `.wiki`, they are actually just regular text files.

<details>
  <summary>Click here for a list of wiki dumps</summary>
  <p>

| Dump script                                               | Filename    | Description |
|-----------------------------------------------------------|-------------|-------------|
| [`ExportWikiBOOK.pas`](Edit%20scripts/ExportWikiBOOK.pas) | `BOOK.wiki` | Notes       |
| [`ExportWikiDIAL.pas`](Edit%20scripts/ExportWikiDIAL.pas) | `DIAL.wiki` | Dialogue    |
| [`ExportWikiNOTE.pas`](Edit%20scripts/ExportWikiNOTE.pas) | `NOTE.wiki` | Holodisks   |
| [`ExportWikiTERM.pas`](Edit%20scripts/ExportWikiTERM.pas) | `TERM.wiki` | Terminals   |

  </p>
</details>

## Generation
All dumps have been created using [xEdit](https://tes5edit.github.io/) scripts, which are written in [a special form of Object Pascal](https://tes5edit.github.io/docs/11-Scripting-Functions.html#s_11-7).
The scripts can be found in the `Edit scripts` directory.
For more information on the optimal procedure, see [the wiki page on generating dumps](https://github.com/FWDekker/fo76-dumps/wiki/Generating-dumps).

## Contact
* Bugs can be reported on the [Issues](https://github.com/FWDekker/fo76-dumps/issues) page.
* Feature requests can be made on the [Issues](https://github.com/FWDekker/fo76-dumps/issues) page.
* Questions can be asked on [my Fallout Wiki talk page](https://fallout.fandom.com/wiki/User_talk:FDekker) or by emailing me.

## Credits
* [AYF](https://fallout.fandom.com/wiki/User:AllYourFavorites), for regularly reminding me to create new dumps.
* [Wully616](https://github.com/Wully616), for [his contributions](https://github.com/FWDekker/fo76-dumps/pull/20) to dumping location data.

## Copyright
The contents of all data dumps in this repository are owned by Bethesda Softworks LLC.
