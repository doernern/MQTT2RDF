# MQTT2RDF Semantic Integration Framework

MQTT2RDF is a reusable semantic integration framework integrates
real-time Knowledge Graph Population with MQTT4SSN, supporting
end-to-end semantic analytics. Further, it addresses the description of heterogeneous
payload formats and character encodings. The framework provides artifacts
for ontology population. MQTT2RDF is build upon the MQTT4SSN ontology, that represents MQTT with its network entities and control packets.

## Artifacts

The framework provides the following artifacts that capture live MQTT traffic from the broker, enable RDF instantiation, and subsequently stream the resulting triples to an RDF store: 

* MQTT4SSN Ontology
* Node-Red Flows
* RML-based mapping files and scripts
* Jupyter Notebook for semantic analysis
* Docker environment

## MQTT4SSN Ontology

[![Format](https://img.shields.io/badge/Format-JSON_LD-blue.svg)](https://doernern.github.io/MQTT4SSNOntology/documentation/ontology.jsonld) [![Format](https://img.shields.io/badge/Format-RDF/XML-blue.svg)](https://doernern.github.io/MQTT4SSNOntology/documentation/ontology.owl) [![Format](https://img.shields.io/badge/Format-N_Triples-blue.svg)](https://doernern.github.io/MQTT4SSNOntology/documentation/ontology.nt) [![Format](https://img.shields.io/badge/Format-TTL-blue.svg)](https://doernern.github.io/MQTT4SSNOntology/documentation/ontology.ttl)

MQTT4SSN is an ontology representing the MQTT transport protocol, containing the transmitted data. It extends the W3C SSN/SOSA ontology with the MQTT transport protocol component and uses the WoT MQTT to RDF draft as an ontology design pattern. The ontology captures the essential elements of MQTT, such as the network entities broker and client, the various control packets and their payloads, the topics that organize communication, and the interrelations between these components. 

### Key Features

* Supports all MQTT 5.0 control packets
* Enables representation of heterogeneous payload formats and character encodings
* Alignment with the well-established W3C SSN/SOSA ontology
* Models the relation between MQTT topic naming and SOSA elements such as FeatureOfInterest, Property, Actuation, ActuationCollection, Observation, and ObservationCollection

### Ontology Documentation 

[![Documentation](https://img.shields.io/badge/Documentation-Ontology_Specification_Draft-blue.svg)](https://doernern.github.io/MQTT4SSNOntology/documentation/index-en.html)

### Ontology Visualization

[![Visualize with](https://img.shields.io/badge/Visualize_with-WebVowl-blue.svg)](https://doernern.github.io/MQTT4SSNOntology/documentation/webvowl/index.html#) 

## License
All resources are licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International.

[![License](https://img.shields.io/badge/License-https://creativecommons.org/licenses/by_nc_sa/4.0/-blue.svg)](https://creativecommons.org/licenses/by-nc-sa/4.0/)
