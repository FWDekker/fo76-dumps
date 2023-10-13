# Changelog
## Unreleased


## [4.0.0] -- 2023-10-13
* **Breaking change:**
  During recursive terminal traversal for `TERM.wiki`, terminals are no longer included more than once.
  The previous behavior, though useful in some cases, would result in out-of-memory errors, excessively large exports,
  and bad performance when exporting quiz-like terminals.
* Add a centrally-kept changelog.
* Replace improper usages of `eByPath` with `eByName`, and use `eByPath` to combine calls.
* Fix several memory leaks.
* Fix incorrect script name in `README.md`.


## [3.2.0] -- 2023-06-21
* Added `ALCH` dumps for ingestibles. (#54)
* Fixed minor code style and performance issues.


## [3.1.0] -- 2023-05-27
* **Breaking change:** The main Python script has been renamed from `export.py` to `fo76dumps.py`.
* **Breaking change:** All paths in `config.py` (and `config_default.py`) should now be of type `Path` instead of type `str`.
* **Breaking change:** Parameter `ba2extract_compatdata_path` in `config.py` (and `config_default.py`) is now interpreted as an absolute path instead of a relative path.
* xEdit dump parts (such as `tabular.IDs.csv.001`) are now moved to the directory `dumps/_parts/` after they have been merged together. Similarly, files that have been archived are now moved to the directory `dumps/_archived/` after archiving has been completed. As a result, all files that should be attached to a release can now be selected instantly.
* Warnings and errors that occur while generating and processing dumps have clearer descriptions now.
* Updated dependencies.


## [3.0.0] -- 2022-07-24
* **New dump:** Credits are dumped in `raw.credits.txt`. (#41)
* **New dump:** Curve tables are dumped in `raw.curvetables.zip`.
* `.ba2` files can now be processed, allowing raw files to be exported from the game.
* xEdit archiving happens in the background of ba2extract.
* Dump scripts can be configured from `config.py`.
* Slimmed-down README, with most information moved over to the [wiki](https://github.com/FWDekker/fo76-dumps/wiki).


## [2.5.3] -- 2022-07-22
* ESMs are optionally archived as a utility. These archives will not be uploaded.


## [2.5.2] -- 2022-03-18
* Linux dump processing script now correctly creates `.ini` parent directory.


## [2.5.1] -- 2022-03-04
* Dump processing script now supports Linux using Proton.


## [2.5.0] -- 2021-05-16
* Dump post-processing has been automated using a Python script.
    * `.7z` archives are created for dumps of at least 10MB instead of at least 10MiB.
    * Column names in the `.db` now contain `_` where the corresponding `.csv` has whitespace.
    * Values in the `.db` now retain all leading and trailing whitespace that are present in the game files.
    * All columns in the `.db` are now of type `TEXT` to prevent lossy and incorrect automatic type detection.


## [2.4.2] -- 2020-12-17
* Renamed all occurrences of variable `e` to `el`.


## [2.4.1] -- 2020-10-05
* Fixed crash when a float is unexpectedly a string.


## [2.4.0] -- 2020-09-29
* New dumps
    * Flora (`FLOR.csv`) (#20)
    * Leveled items (`LVLI.csv`) (#20)
    * Object modifications (`OMOD.csv`) (#21)
    * Weapons (`WEAP.csv`) (#20/#21)
    * Armor locations (`ARMO_LOC.csv`) (#20)
    * Flora locations (`FLOR_LOC.csv`) (#20)
    * Leveled item locations (`LVLI_LOC.csv`) (#20)
    * Miscellaneous item locations (`MISC_LOC.csv`) (#20)
    * Weapon locations (`WEAP_LOC.csv`) (#20)
* Dump changes
    * Properties, components, and faction relations are now expressed as JSON objects instead of strings. (#27)
    * References (e.g. keywords, perks, factions) are now dumped as `<edid> "<name>" [<sig>:<formid>]` (`"<name>"` is optional) instead of only `<edid>`. (#35)
    * Constructible object dumps now use only one column for the product and one column for the recipe, formatted as references. (5bd2b25bfabedb8a758d4bdaf95ee06a5a870b2f)
* Bug fixes
    * Empty script notes in `DIAL.csv` no longer have italics around them. (#26)
    * NPC perks no longer have a trailing `=` in each entry. (#28)
    * JSON is now escaped more properly. (#31)
    * Constructible objects no longer have missing component lists. (#33)
* New script features
    * Exposed `ExportAll` script to xedit without having to run the `fo76pas`. (ce17851a2beed1dbc2f639677aab3bc815ff9145)
    * Ability to select which dump scripts to run when using `ExportAll`. (#23)
    * Terminal dumps are now exported in parts, like ID exports. (#24)
    * Create `_done.txt` after `ExportAll` has finished. (#25)
    * Display error report after `ExportAll` has finished. (#29)


## [2.3.0] -- 2020-05-21
* Added image path fields for `ENTM` records. (#19)


## [2.2.0] -- 2020-04-24
* Added armour dump (`ARMO.csv`) (#17).
* Added outfit dump (`OTFT.csv`).
* Added default outfit field to `NPC_.csv`.
* Added description field to `ENTM.csv`.


## [2.1.0] -- 2020-04-20
* Replaced `ERROR` strings in holotape exports with more extensive error messages. (#14)
* Holotapes with terminal contents now have a reference to the terminal in question. (#15)
* Unreferenced terminal entries are now also exported, hence the need to compress the exported file. (#15)
* Include more information about NPCs, in particular about their appearance. (#16)


## [2.0.0] -- 2020-01-18
* **Flattened lists have been replaced with JSON arrays in all tabular exports.**
* Flattened lists are now sorted alphabetically.
* Added `FACT.csv`.
* The `Item name` column in `MISC.csv` has been renamed to `Name`.
* Fixed a bug where double quotes (`"`) were not properly escaped in CSVs.


## [1.5.1] -- 2019-10-16
* **Dumps no longer order records by base ID.**
* `TERM.wiki` no longer features unnecessary headers.
* `TERM.wiki` now puts the transcript template around all transcripts.
* Cleaned up some scripts (#4, #5).
* Added `ExportAll.fo76pas` file to automatically run all export scripts in sequence.


## [1.5.0] -- 2019-09-17
* Added `ENTM.csv`, `CLAS.csv`, `NPC_.csv`, and `RACE.csv` dumps.


## [1.4.1] -- 2019-09-10
* Added more information to `COBJ.csv`.
* Added editor IDs to `BOOK.wiki` and `NOTE.csv`.


## [1.4.0] -- 2019-06-26
* Added ESM name to all records in all exports.


## [1.3.1] -- 2019-06-01
* Export scripts now check record signature before trying to export it.
* Export scripts now follow a common style guide.


## [1.3.0] -- 2019-05-13
* Added `MISC.csv`.
* Added `DIAL.wiki`.


## [1.2.0] -- 2019-04-22
* Reduced `IDs.csv` script memory consumption by outputting export in parts.
* Added keywords column to `IDs.csv`.
* Added `SCRAP.csv`.
* Added `COBJ.csv`.


## [1.1.0] -- 2019-02-26
* Added `BOOK.wiki`.
* Added `TERM.wiki`.


## [1.0.0] -- 2019-02-05
Initial release.
