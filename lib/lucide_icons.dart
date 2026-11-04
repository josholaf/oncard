import 'package:flutter/material.dart';

/// Icons from the Lucide icon set (https://lucide.dev), open source under
/// the ISC license. Each entry maps an icon name to normalized SVG path
/// data on a 24x24 grid. Rendered by [LucideIcon] as 2px round strokes.
const Map<String, List<String>> kLucideIcons = <String, List<String>>{
  'graduation-cap': <String>['M21.42 10.922a1 1 0 0 0-.019-1.838L12.83 5.18a2 2 0 0 0-1.66 0L2.6 9.08a1 1 0 0 0 0 1.832l8.57 3.908a2 2 0 0 0 1.66 0z', 'M22 10v6', 'M6 12.5V16a6 3 0 0 0 12 0v-3.5'],

  'graduation-cap': <String>['M21.42 10.922a1 1 0 0 0-.019-1.838L12.83 5.18a2 2 0 0 0-1.66 0L2.6 9.08a1 1 0 0 0 0 1.832l8.57 3.908a2 2 0 0 0 1.66 0z', 'M22 10v6', 'M6 12.5V16a6 3 0 0 0 12 0v-3.5'],
  'book-open': <String>['M12 5v16', 'M20.001 19A2 2 0 0022 17V5a2 2 0 00-1.999-2L16 3.002A5 5 0 0012 5a5 5 0 00-4-2H4a2 2 0 00-2 2v12a2 2 0 001.999 2H8a5 5 0 014 2 5 5 0 014-2z'],
  'book': <String>['M4 19.5v-15A2.5 2.5 0 0 1 6.5 2H19a1 1 0 0 1 1 1v18a1 1 0 0 1-1 1H6.5a1 1 0 0 1 0-5H20'],
  'library': <String>['m16 6 4 14', 'M12 6v14', 'M8 8v12', 'M4 4v16'],
  'school': <String>['M14 21v-3a2 2 0 0 0-4 0v3', 'M18 4.933V21', 'm4 6 7.106-3.79a2 2 0 0 1 1.788 0L20 6', 'm6 11-3.52 2.147a1 1 0 0 0-.48.854V19a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2v-5a1 1 0 0 0-.48-.853L18 11', 'M6 4.933V21', 'M 10 9 A 2 2 0 1 0 14 9 A 2 2 0 1 0 10 9 Z'],
  'brain': <String>['M12 18V5', 'M15 13a4.17 4.17 0 01-3-4 4.17 4.17 0 01-3 4', 'M17.707 6.294A3 3 0 1012 5a3 3 0 10-5.707 1.294', 'M17.996 5.125a4 4 0 012.526 5.77', 'M18 18a4 4 0 002-7.465', 'M19.967 17.482a4 4 0 11-7.967.517 4 4 0 11-7.967-.517', 'M6 18a4 4 0 01-2-7.465', 'M6.004 5.125a4 4 0 00-2.526 5.77'],
  'microscope': <String>['M6 18h8', 'M3 22h18', 'M14 22a7 7 0 1 0 0-14h-1', 'M9 14h2', 'M9 12a2 2 0 0 1-2-2V6h6v4a2 2 0 0 1-2 2Z', 'M12 6V3a1 1 0 0 0-1-1H9a1 1 0 0 0-1 1v3'],
  'flask-conical': <String>['M14 2v6a2 2 0 0 0 .245.96l5.51 10.08A2 2 0 0 1 18 22H6a2 2 0 0 1-1.755-2.96l5.51-10.08A2 2 0 0 0 10 8V2', 'M6.453 15h11.094', 'M8.5 2h7'],
  'atom': <String>['M 11 12 A 1 1 0 1 0 13 12 A 1 1 0 1 0 11 12 Z', 'M20.2 20.2c2.04-2.03.02-7.36-4.5-11.9-4.54-4.52-9.87-6.54-11.9-4.5-2.04 2.03-.02 7.36 4.5 11.9 4.54 4.52 9.87 6.54 11.9 4.5Z', 'M15.7 15.7c4.52-4.54 6.54-9.87 4.5-11.9-2.03-2.04-7.36-.02-11.9 4.5-4.52 4.54-6.54 9.87-4.5 11.9 2.03 2.04 7.36.02 11.9-4.5Z'],
  'dna': <String>['m10 16 1.5 1.5', 'm14 8-1.5-1.5', 'M15 2c-1.798 1.998-2.518 3.995-2.807 5.993', 'm16.5 10.5 1 1', 'm17 6-2.891-2.891', 'M2 15c6.667-6 13.333 0 20-6', 'm20 9 .891.891', 'M3.109 14.109 4 15', 'm6.5 12.5 1 1', 'm7 18 2.891 2.891', 'M9 22c1.798-1.998 2.518-3.995 2.807-5.993'],
  'telescope': <String>['m10.065 12.493-6.18 1.318a.934.934 0 0 1-1.108-.702l-.537-2.15a1.07 1.07 0 0 1 .691-1.265l13.504-4.44', 'm13.56 11.747 4.332-.924', 'm16 21-3.105-6.21', 'M16.485 5.94a2 2 0 0 1 1.455-2.425l1.09-.272a1 1 0 0 1 1.212.727l1.515 6.06a1 1 0 0 1-.727 1.213l-1.09.272a2 2 0 0 1-2.425-1.455z', 'm6.158 8.633 1.114 4.456', 'm8 21 3.105-6.21', 'M 10 13 A 2 2 0 1 0 14 13 A 2 2 0 1 0 10 13 Z'],
  'calculator': <String>['M 6 2 H 18 A 2 2 0 0 1 20 4 V 20 A 2 2 0 0 1 18 22 H 6 A 2 2 0 0 1 4 20 V 4 A 2 2 0 0 1 6 2 Z', 'M 8 6 L 16 6', 'M 16 14 L 16 18', 'M16 10h.01', 'M12 10h.01', 'M8 10h.01', 'M12 14h.01', 'M8 14h.01', 'M12 18h.01', 'M8 18h.01'],
  'lightbulb': <String>['M15 14c.2-1 .7-1.7 1.5-2.5 1-.9 1.5-2.2 1.5-3.5A6 6 0 0 0 6 8c0 1 .2 2.2 1.5 3.5.7.7 1.3 1.5 1.5 2.5', 'M9 18h6', 'M10 22h4'],
  'pencil': <String>['M21.174 6.812a1 1 0 0 0-3.986-3.987L3.842 16.174a2 2 0 0 0-.5.83l-1.321 4.352a.5.5 0 0 0 .623.622l4.353-1.32a2 2 0 0 0 .83-.497z', 'm15 5 4 4'],
  'pen-line': <String>['M13 21h8', 'M21.174 6.812a1 1 0 0 0-3.986-3.987L3.842 16.174a2 2 0 0 0-.5.83l-1.321 4.352a.5.5 0 0 0 .623.622l4.353-1.32a2 2 0 0 0 .83-.497z'],
  'notebook-pen': <String>['M13.4 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2v-7.4', 'M2 6h4', 'M2 10h4', 'M2 14h4', 'M2 18h4', 'M21.378 5.626a1 1 0 1 0-3.004-3.004l-5.01 5.012a2 2 0 0 0-.506.854l-.837 2.87a.5.5 0 0 0 .62.62l2.87-.837a2 2 0 0 0 .854-.506z'],
  'clipboard-list': <String>['M 9 2 H 15 A 1 1 0 0 1 16 3 V 5 A 1 1 0 0 1 15 6 H 9 A 1 1 0 0 1 8 5 V 3 A 1 1 0 0 1 9 2 Z', 'M16 4h2a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2h2', 'M12 11h4', 'M12 16h4', 'M8 11h.01', 'M8 16h.01'],
  'file-text': <String>['M6 22a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h8a2.4 2.4 0 0 1 1.704.706l3.588 3.588A2.4 2.4 0 0 1 20 8v12a2 2 0 0 1-2 2z', 'M14 2v5a1 1 0 0 0 1 1h5', 'M10 9H8', 'M16 13H8', 'M16 17H8'],
  'folder': <String>['M20 20a2 2 0 0 0 2-2V8a2 2 0 0 0-2-2h-7.9a2 2 0 0 1-1.69-.9L9.6 3.9A2 2 0 0 0 7.93 3H4a2 2 0 0 0-2 2v13a2 2 0 0 0 2 2Z'],
  'bookmark': <String>['M17 3a2 2 0 0 1 2 2v15a1 1 0 0 1-1.496.868l-4.512-2.578a2 2 0 0 0-1.984 0l-4.512 2.578A1 1 0 0 1 5 20V5a2 2 0 0 1 2-2z'],
  'tag': <String>['M12.586 2.586A2 2 0 0 0 11.172 2H4a2 2 0 0 0-2 2v7.172a2 2 0 0 0 .586 1.414l8.704 8.704a2.426 2.426 0 0 0 3.42 0l6.58-6.58a2.426 2.426 0 0 0 0-3.42z', 'M 7 7.5 A 0.5 0.5 0 1 0 8 7.5 A 0.5 0.5 0 1 0 7 7.5 Z'],
  'star': <String>['M11.525 2.295a.53.53 0 0 1 .95 0l2.31 4.679a2.123 2.123 0 0 0 1.595 1.16l5.166.756a.53.53 0 0 1 .294.904l-3.736 3.638a2.123 2.123 0 0 0-.611 1.878l.882 5.14a.53.53 0 0 1-.771.56l-4.618-2.428a2.122 2.122 0 0 0-1.973 0L6.396 21.01a.53.53 0 0 1-.77-.56l.881-5.139a2.122 2.122 0 0 0-.611-1.879L2.16 9.795a.53.53 0 0 1 .294-.906l5.165-.755a2.122 2.122 0 0 0 1.597-1.16z'],
  'target': <String>['M 2 12 A 10 10 0 1 0 22 12 A 10 10 0 1 0 2 12 Z', 'M 6 12 A 6 6 0 1 0 18 12 A 6 6 0 1 0 6 12 Z', 'M 10 12 A 2 2 0 1 0 14 12 A 2 2 0 1 0 10 12 Z'],
  'globe': <String>['M 2 12 A 10 10 0 1 0 22 12 A 10 10 0 1 0 2 12 Z', 'M12 2a14.5 14.5 0 0 0 0 20 14.5 14.5 0 0 0 0-20', 'M2 12h20'],
  'film': <String>['M 5 3 H 19 A 2 2 0 0 1 21 5 V 19 A 2 2 0 0 1 19 21 H 5 A 2 2 0 0 1 3 19 V 5 A 2 2 0 0 1 5 3 Z', 'M7 3v18', 'M3 7.5h4', 'M3 12h18', 'M3 16.5h4', 'M17 3v18', 'M17 7.5h4', 'M17 16.5h4'],
  'apple': <String>['M12 6.528V3a1 1 0 0 1 1-1h0', 'M18.237 21A15 15 0 0 0 22 11a6 6 0 0 0-10-4.472A6 6 0 0 0 2 11a15.1 15.1 0 0 0 3.763 10 3 3 0 0 0 3.648.648 5.5 5.5 0 0 1 5.178 0A3 3 0 0 0 18.237 21'],
  'wallet': <String>['M19 7V4a1 1 0 0 0-1-1H5a2 2 0 0 0 0 4h15a1 1 0 0 1 1 1v4h-3a2 2 0 0 0 0 4h3a1 1 0 0 0 1-1v-2a1 1 0 0 0-1-1', 'M3 5v14a2 2 0 0 0 2 2h15a1 1 0 0 0 1-1v-4'],
  'briefcase': <String>['M16 20V4a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v16', 'M 4 6 H 20 A 2 2 0 0 1 22 8 V 18 A 2 2 0 0 1 20 20 H 4 A 2 2 0 0 1 2 18 V 8 A 2 2 0 0 1 4 6 Z'],
  'umbrella': <String>['M12 13v7a2 2 0 0 0 4 0', 'M12 2v2', 'M20.992 13a1 1 0 0 0 .97-1.274 10.284 10.284 0 0 0-19.923 0A1 1 0 0 0 3 13z'],
  'glasses': <String>['M 2 15 A 4 4 0 1 0 10 15 A 4 4 0 1 0 2 15 Z', 'M 14 15 A 4 4 0 1 0 22 15 A 4 4 0 1 0 14 15 Z', 'M14 15a2 2 0 0 0-2-2 2 2 0 0 0-2 2', 'M2.5 13 5 7c.7-1.3 1.4-2 3-2', 'M21.5 13 19 7c-.7-1.3-1.5-2-3-2'],
  'sunrise': <String>['M12 2v8', 'm4.93 10.93 1.41 1.41', 'M2 18h2', 'M20 18h2', 'm19.07 10.93-1.41 1.41', 'M22 22H2', 'm8 6 4-4 4 4', 'M16 18a4 4 0 0 0-8 0'],
  'trophy': <String>['M10 14.66V17a1 1 0 0 1-1 1 2 2 0 0 0-2 2v2', 'M14 14.66V17a1 1 0 0 0 1 1 2 2 0 0 1 2 2v2', 'M17.916 10H19.5A2.5 2.5 0 0 0 22 7.5V5a1 1 0 0 0-1-1h-3', 'M4 22h16', 'M6 9a6 6 0 0 0 12 0V3a1 1 0 0 0-1-1H7a1 1 0 0 0-1 1z', 'M6.084 10H4.5A2.5 2.5 0 0 1 2 7.5V5a1 1 0 0 1 1-1h3'],
  'medal': <String>['M7.21 15 2.66 7.14a2 2 0 0 1 .13-2.2L4.4 2.8A2 2 0 0 1 6 2h12a2 2 0 0 1 1.6.8l1.6 2.14a2 2 0 0 1 .14 2.2L16.79 15', 'M11 12 5.12 2.2', 'm13 12 5.88-9.8', 'M8 7h8', 'M 7 17 A 5 5 0 1 0 17 17 A 5 5 0 1 0 7 17 Z', 'M12 18v-2h-.5'],
  'award': <String>['m15.477 12.89 1.515 8.526a.5.5 0 0 1-.81.47l-3.58-2.687a1 1 0 0 0-1.197 0l-3.586 2.686a.5.5 0 0 1-.81-.469l1.514-8.526', 'M 6 8 A 6 6 0 1 0 18 8 A 6 6 0 1 0 6 8 Z'],
  'rocket': <String>['M12 15v5s3.03-.55 4-2c1.08-1.62 0-5 0-5', 'M4.5 16.5c-1.5 1.26-2 5-2 5s3.74-.5 5-2c.71-.84.7-2.13-.09-2.91a2.18 2.18 0 0 0-2.91-.09', 'M9 12a22 22 0 0 1 2-3.95A12.88 12.88 0 0 1 22 2c0 2.72-.78 7.5-6 11a22.4 22.4 0 0 1-4 2z', 'M9 12H4s.55-3.03 2-4c1.62-1.08 5 .05 5 .05'],
  'map': <String>['M14.106 5.553a2 2 0 0 0 1.788 0l3.659-1.83A1 1 0 0 1 21 4.619v12.764a1 1 0 0 1-.553.894l-4.553 2.277a2 2 0 0 1-1.788 0l-4.212-2.106a2 2 0 0 0-1.788 0l-3.659 1.83A1 1 0 0 1 3 19.381V6.618a1 1 0 0 1 .553-.894l4.553-2.277a2 2 0 0 1 1.788 0z', 'M15 5.764v15', 'M9 3.236v15'],
  'compass': <String>['M 2 12 A 10 10 0 1 0 22 12 A 10 10 0 1 0 2 12 Z', 'm16.24 7.76-1.804 5.411a2 2 0 0 1-1.265 1.265L7.76 16.24l1.804-5.411a2 2 0 0 1 1.265-1.265z'],
  'languages': <String>['m5 8 6 6', 'm4 14 6-6 2-3', 'M2 5h12', 'M7 2h1', 'm22 22-5-10-5 10', 'M14 18h6'],
  'mic': <String>['M12 19v3', 'M19 10v2a7 7 0 0 1-14 0v-2', 'M 12 2 H 12 A 3 3 0 0 1 15 5 V 12 A 3 3 0 0 1 12 15 H 12 A 3 3 0 0 1 9 12 V 5 A 3 3 0 0 1 12 2 Z'],
  'headphones': <String>['M3 14h3a2 2 0 0 1 2 2v3a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-7a9 9 0 0 1 18 0v7a2 2 0 0 1-2 2h-1a2 2 0 0 1-2-2v-3a2 2 0 0 1 2-2h3'],
  'piano': <String>['M10 13v4', 'M14 13v4', 'M18 13v4', 'M2 13h20', 'M22 11.5A3.5 3.5 0 0018.5 8a3.52 3.52 0 01-3.173-2A7 7 0 002 9v10a2 2 0 002 2h16a2 2 0 002-2z', 'M6 13v4'],
  'guitar': <String>['m11.9 12.1 4.514-4.514', 'M20.1 2.3a1 1 0 0 0-1.4 0l-1.114 1.114A2 2 0 0 0 17 4.828v1.344a2 2 0 0 1-.586 1.414A2 2 0 0 1 17.828 7h1.344a2 2 0 0 0 1.414-.586L21.7 5.3a1 1 0 0 0 0-1.4z', 'm6 16 2 2', 'M8.23 9.85A3 3 0 0 1 11 8a5 5 0 0 1 5 5 3 3 0 0 1-1.85 2.77l-.92.38A2 2 0 0 0 12 18a4 4 0 0 1-4 4 6 6 0 0 1-6-6 4 4 0 0 1 4-4 2 2 0 0 0 1.85-1.23z'],
  'palette': <String>['M12 22a1 1 0 0 1 0-20 10 9 0 0 1 10 9 5 5 0 0 1-5 5h-2.25a1.75 1.75 0 0 0-1.4 2.8l.3.4a1.75 1.75 0 0 1-1.4 2.8z', 'M 13 6.5 A 0.5 0.5 0 1 0 14 6.5 A 0.5 0.5 0 1 0 13 6.5 Z', 'M 17 10.5 A 0.5 0.5 0 1 0 18 10.5 A 0.5 0.5 0 1 0 17 10.5 Z', 'M 6 12.5 A 0.5 0.5 0 1 0 7 12.5 A 0.5 0.5 0 1 0 6 12.5 Z', 'M 8 7.5 A 0.5 0.5 0 1 0 9 7.5 A 0.5 0.5 0 1 0 8 7.5 Z'],
  'camera': <String>['M13.997 4a2 2 0 0 1 1.76 1.05l.486.9A2 2 0 0 0 18.003 7H20a2 2 0 0 1 2 2v9a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V9a2 2 0 0 1 2-2h1.997a2 2 0 0 0 1.759-1.048l.489-.904A2 2 0 0 1 10.004 4z', 'M 9 13 A 3 3 0 1 0 15 13 A 3 3 0 1 0 9 13 Z'],
  'code': <String>['m16 18 6-6-6-6', 'm8 6-6 6 6 6'],
  'terminal': <String>['M12 19h8', 'm4 17 6-6-6-6'],
  'database': <String>['M3 5V19A9 3 0 0 0 21 19V5', 'M3 12A9 3 0 0 0 21 12'],
  'cpu': <String>['M12 20v2', 'M12 2v2', 'M17 20v2', 'M17 2v2', 'M2 12h2', 'M2 17h2', 'M2 7h2', 'M20 12h2', 'M20 17h2', 'M20 7h2', 'M7 20v2', 'M7 2v2', 'M 6 4 H 18 A 2 2 0 0 1 20 6 V 18 A 2 2 0 0 1 18 20 H 6 A 2 2 0 0 1 4 18 V 6 A 2 2 0 0 1 6 4 Z', 'M 9 8 H 15 A 1 1 0 0 1 16 9 V 15 A 1 1 0 0 1 15 16 H 9 A 1 1 0 0 1 8 15 V 9 A 1 1 0 0 1 9 8 Z'],
  'smartphone': <String>['M 7 2 H 17 A 2 2 0 0 1 19 4 V 20 A 2 2 0 0 1 17 22 H 7 A 2 2 0 0 1 5 20 V 4 A 2 2 0 0 1 7 2 Z', 'M12 18h.01'],
  'laptop': <String>['M18 5a2 2 0 0 1 2 2v8.526a2 2 0 0 0 .212.897l1.068 2.127a1 1 0 0 1-.9 1.45H3.62a1 1 0 0 1-.9-1.45l1.068-2.127A2 2 0 0 0 4 15.526V7a2 2 0 0 1 2-2z', 'M20.054 15.987H3.946'],
  'wifi': <String>['M12 20h.01', 'M2 8.82a15 15 0 0 1 20 0', 'M5 12.859a10 10 0 0 1 14 0', 'M8.5 16.429a5 5 0 0 1 7 0'],
  'cloud': <String>['M17.5 19H9a7 7 0 1 1 6.71-9h1.79a4.5 4.5 0 1 1 0 9Z'],
  'battery': <String>['M 22 14 L 22 10', 'M 4 6 H 16 A 2 2 0 0 1 18 8 V 16 A 2 2 0 0 1 16 18 H 4 A 2 2 0 0 1 2 16 V 8 A 2 2 0 0 1 4 6 Z'],
  'zap': <String>['M15.914 4a1.5 1.5 0 00-2.474-1.561l-9 9A1.5 1.5 0 005.5 14h4.002a.5.5 0 01.471.666L8.086 20a1.5 1.5 0 002.475 1.56l9-9A1.5 1.5 0 0018.5 10h-3.997a.5.5 0 01-.472-.667z'],
};

/// Renders a Lucide icon by [name] at [size], stroked in [color].
class LucideIcon extends StatelessWidget {
  final String name;
  final double size;
  final Color? color;
  const LucideIcon({super.key, required this.name, this.size = 24, this.color});

  @override
  Widget build(BuildContext context) {
    final paths = kLucideIcons[name];
    if (paths == null) {
      return SizedBox(width: size, height: size);
    }
    final c = color ?? Theme.of(context).colorScheme.onSurface;
    return CustomPaint(
      size: Size.square(size),
      painter: _LucidePainter(paths, c),
    );
  }
}

class _LucidePainter extends CustomPainter {
  final List<String> paths;
  final Color color;
  const _LucidePainter(this.paths, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.save();
    canvas.scale(size.width / 24);
    for (final d in paths) {
      canvas.drawPath(parseSvgPath(d), paint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_LucidePainter old) =>
      old.color != color || old.paths != paths;
}

/// Minimal SVG path parser covering the commands Lucide data uses:
/// M/m L/l H/h V/v C/c S/s Q/q T/t A/a Z/z on a 24x24 grid.
Path parseSvgPath(String d) {
  final path = Path();
  final tokens =
      RegExp(r'([A-Za-z])|([-+]?[0-9]*\.?[0-9]+)').allMatches(d).toList();
  var cx = 0.0, cy = 0.0; // current point
  var sx = 0.0, sy = 0.0; // subpath start
  var px = 0.0, py = 0.0; // last cubic control point
  var qx = 0.0, qy = 0.0; // last quad control point
  var i = 0;

  double next() => double.parse(tokens[i++].group(0)!);
  bool hasNext() => i < tokens.length && tokens[i].group(1) == null;

  while (i < tokens.length) {
    final cmd = tokens[i].group(1);
    if (cmd == null) break;
    i++;
    final rel = cmd.toLowerCase() == cmd;
    switch (cmd) {
      case 'M':
      case 'm':
        while (true) {
          final x = next(), y = next();
          cx = rel ? cx + x : x;
          cy = rel ? cy + y : y;
          path.moveTo(cx, cy);
          sx = cx; sy = cy;
          if (!hasNext()) break;
        }
        break;
      case 'L':
      case 'l':
        while (hasNext()) {
          final x = next(), y = next();
          cx = rel ? cx + x : x;
          cy = rel ? cy + y : y;
          path.lineTo(cx, cy);
        }
        break;
      case 'H':
      case 'h':
        while (hasNext()) {
          final x = next();
          cx = rel ? cx + x : x;
          path.lineTo(cx, cy);
        }
        break;
      case 'V':
      case 'v':
        while (hasNext()) {
          final y = next();
          cy = rel ? cy + y : y;
          path.lineTo(cx, cy);
        }
        break;
      case 'C':
      case 'c':
        while (hasNext()) {
          var x1 = next(), y1 = next(), x2 = next(), y2 = next(), x = next(), y = next();
          if (rel) { x1 += cx; y1 += cy; x2 += cx; y2 += cy; x += cx; y += cy; }
          path.cubicTo(x1, y1, x2, y2, x, y);
          px = x2; py = y2;
          cx = x; cy = y;
        }
        break;
      case 'S':
      case 's':
        while (hasNext()) {
          var x2 = next(), y2 = next(), x = next(), y = next();
          if (rel) { x2 += cx; y2 += cy; x += cx; y += cy; }
          final x1 = 2 * cx - px, y1 = 2 * cy - py;
          path.cubicTo(x1, y1, x2, y2, x, y);
          px = x2; py = y2;
          cx = x; cy = y;
        }
        break;
      case 'Q':
      case 'q':
        while (hasNext()) {
          var x1 = next(), y1 = next(), x = next(), y = next();
          if (rel) { x1 += cx; y1 += cy; x += cx; y += cy; }
          path.quadraticBezierTo(x1, y1, x, y);
          qx = x1; qy = y1;
          cx = x; cy = y;
        }
        break;
      case 'T':
      case 't':
        while (hasNext()) {
          final x = next(), y = next();
          cx = rel ? cx + x : x;
          cy = rel ? cy + y : y;
          final x1 = 2 * cx - qx, y1 = 2 * cy - qy;
          path.quadraticBezierTo(x1, y1, cx, cy);
          qx = x1; qy = y1;
        }
        break;
      case 'A':
      case 'a':
        while (hasNext()) {
          final rx = next(), ry = next(), rot = next();
          final large = next(), sweep = next();
          final x = next(), y = next();
          final tx = rel ? cx + x : x;
          final ty = rel ? cy + y : y;
          path.arcToPoint(
            Offset(tx, ty),
            radius: Radius.elliptical(rx, ry),
            rotation: rot,
            largeArc: large > 0.5,
            clockwise: sweep > 0.5,
          );
          cx = tx; cy = ty;
        }
        break;
      case 'Z':
      case 'z':
        path.close();
        cx = sx; cy = sy;
        break;
    }
  }
  return path;
}
