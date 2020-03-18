# ESWC SoftwareKG

SoftwareKG is a knowledge graph that contains software mentions of 51,165 articles from PLoS that are tagged with the keyword "Social Science".
The software mentions are automatically extracted by use of a automated pipeline. more than 133,000 software mention were identified.
The software mentions were then linked by use of their potential abbreviations and the DBpedia.
The identified software mentions then structured in the SoftwareKG together with meta data about the articles.
The data is represented in an RDF/S model by using established W3C standards and vocabularies.

More information about SoftwareKG is provided at https://data.gesis.org/softwarekg/site/.


This repository contains:

* N-Triples file for the final SoftwareKG: `software_kg.zip`
* Reference to the source code necessary to reproduce the results `softwareKG`
* SoSciSoCi corpus used for training and evaluation of the NER model `SoSciSoCi`

The LICENCE file applies to the file `software_kg.zip` only.


The work is described and used in the following publication:

David Schindler and Benjamin Zapilko and Frank Krüger:
*Investigating Software Usage in the Social Sciences: A Knowledge Graph Approach*,
In Proceedings of the 17th Extended Semantic Web Conference,
Heraklion, Crete, Greece,
May 31 - June 4 2020

Please cite this publication, when using the corpus.

Shield: [![CC BY 4.0][cc-by-shield]][cc-by]

This work is licensed under a [Creative Commons Attribution 4.0 International
License][cc-by].

[![CC BY 4.0][cc-by-image]][cc-by]

[cc-by]: http://creativecommons.org/licenses/by/4.0/
[cc-by-image]: https://i.creativecommons.org/l/by/4.0/88x31.png
[cc-by-shield]: https://img.shields.io/badge/License-CC%20BY%204.0-lightgrey.svg
