# psgScore
[![Project Status: WIP – Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)
![Licence](https://img.shields.io/github/license/mnavarretem/psgScore)

**psgScore** is a graphical user interface (GUI) developed in MATLAB for scoring of human sleep. 

**psgScore** is an extensive, flexible and open source sleep diagnostic solution that simplifies the setup, review, analysis and reporting of experimental sleep studies. 

**psgScore** is [Fieldtrip](http://www.fieldtriptoolbox.org/) compatible and requires Fieldtrip toolbox for reading files 

**psgScore** implements different documented algorithms for sleep features detection, it provides several tools for signal visualization and manipulation, among which are found:
 - Channel(s) selection.
 - Display of multiple signal at the same time.
 - Several zoom and grid options (time, amplitude, etc.)
 - Possibility to make time and amplitude measurements directly on the signals.
 - Slow wave, spindle, eye movements, arousal detection.
 

## Installation
Get the source code available at https://github.com/mnavarretem/psgScore/

Add **psgScore** files to the MATLAB path: [Home > Set Path > Add with subfolders]

or typing in the command window:
``` Matlab
addpath(genpath(c:/~your-psgScore-basefolder));
```

## Usage
If **psgScore**  files are in the MATLAB path, write the script name on the workspace

EEG files should be first converted in psgScore format. For this, open [pr_preprocessSleepStaging](https://github.com/mnavarretem/psgScore/blob/master/pr_preprocessSleepStaging.m), set the folder for EEG files and select channels to read. Then, run [pr_preprocessSleepStaging](https://github.com/mnavarretem/psgScore/blob/master/pr_preprocessSleepStaging.m) to process the raw data. 

After preprocessing finishes, open the psgScore GUI to import and visualize the data: 
``` Matlab
pr_psgScore
```

## Support
I encourage to report any issues at https://github.com/mnavarretem/psgScore/issues

Nevertheless, any questions and suggestions can be addressed to:
Miguel Navarrete (mnavarretem@gmail.com)

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

## Project status
WIP – Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.

## Authors

* **Miguel Navarrete** - *Initial work* - [mnavarretem](https://github.com/mnavarretem)

## Licence
[GNU-GPLv3] https://www.gnu.org/licenses/gpl-3.0.html
This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
