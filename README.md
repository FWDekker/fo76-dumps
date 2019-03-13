# Fallout 76 data dumps
This repository contains a number of data dumps of _Fallout 76_ in several formats.
The dumps have last been updated for version 1.1.0.8 of _Fallout 76_.

## Files
### Tabular
Tabular dumps are a simplified sort of dump that contains only the most important information. These records should be very easy to understand by anyone. For more information on how to browse them, check [the wiki page](https://github.com/FWDekker/fo76-dumps/wiki/Browsing-CSV-files).

<details>
  <summary>Click here for a list of tabular dumps</summary>
  <p>

| Source           | File       | Description                     |
|------------------|------------|---------------------------------|
| `SeventySix.esm` | `IDs.csv`  | Form IDs, editor IDs, and names |
| `SeventySix.esm` | `GLOB.csv` | Global variables                |
| `SeventySix.esm` | `GMST.csv` | Game settings                   |

  </p>
</details>

### Wiki
Wiki dumps are generated for the [Fallout Wiki](https://fallout.wikia.com/) and use [MediaWiki](https://www.mediawiki.org) templates. These dumps are useful when editing the wiki. Even though the extension is `.wiki`, they are actually just regular text files.

<details>
  <summary>Click here for a list of wiki dumps</summary>
  <p>

| Source           | File        | Description |
|------------------|-------------|-------------|
| `SeventySix.esm` | `BOOK.wiki` | Notes       |
| `SeventySix.esm` | `NOTE.wiki` | Holodisks   |
| `SeventySix.esm` | `TERM.wiki` | Terminals   |

  </p>
</details>

## Generation
All dumps have been created using [xEdit](https://tes5edit.github.io/) scripts, which are written in [a special form of Object Pascal](https://tes5edit.github.io/docs/11-Scripting-Functions.html#s_11-7). The scripts can be found in the `Edit scripts` directories.

## Contact
* Bugs can be reported on the [Issues](https://github.com/FWDekker/fo76-dumps/issues) page.
* Feature requests can be made on the [Issues](https://github.com/FWDekker/fo76-dumps/issues) page.
* Questions can be asked on [my Fallout Wiki talk page](https://fallout.wikia.com/wiki/User_talk:FDekker) or by emailing me.

## Copyright
The contents of all data dumps in this repository are owned by Bethesda Softworks LLC.
