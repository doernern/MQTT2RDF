# MQTT2RDF – User Manual

## 1. Overview

**MQTT2RDF** is a framework for capturing MQTT control packets and application payloads, normalizing them, and transforming them into `RDF` using `RML` mappings. The resulting `RDF` data is stored in a triplestore and modeled using the **MQTT4SSN ontology** and the **SOSA vocabulary**. The framework is modular and adaptable, allowing different MQTT payload formats, mapping strategies, and deployment scenarios.

## 2. Architecture and Processing Pipeline

The MQTT2RDF framework consists of the following main components:

- **MQTT Broker**: EMQX  
- **Traffic Capture & Preprocessing**: Node-RED  
- **RDF Mapping**: RMLMapper  
- **Triplestore**: GraphDB  
- **Semantic Analytics**: Jupyter Notebook  

### Message Processing Workflow

1. An HTTP node in **Node-RED** listens to the MQTT broker via EMQX webhooks.
2. A switch node identifies the MQTT control packet type.
3. Packet-specific function nodes normalize metadata into unified `JSON` files.
4. `PUBLISH` packets extract and transform payloads (`CSV`, `JSON`, or plain text).
5. RML mappings transform `JSON` into `RDF` and upload it to GraphDB.
6. Messages are processed immediately upon reception.

## 3. Ontology and Semantic Model

The framework relies on the MQTT4SSN ontology, which extends SOSA to represent MQTT-based communication and sensing semantics. **Ontology URL:** https://www.w3id.org/MQTT4SSN-Ontology/

### Loading the Ontology into GraphDB

Before running the framework, the ontology must be loaded into GraphDB:

1. Open the GraphDB web interface at `http://localhost:7200`.
2. Create or select a repository.
3. Upload the [MQTT4SSN ontology](https://www.w3id.org/MQTT4SSN-Ontology/) and [SOSA vocabulary](https://www.w3.org/TR/vocab-ssn/)
4. Ensure the ontology is indexed and available for querying and inference.

## 4. Repository Structure

```text
MQTT2RDF/
├── data/
│   ├── in/                     # Normalized JSON input files
│   │   └── *.json
│   └── out/                    # Generated RDF output files
│       └── *.ttl
├── emqx/                       # MQTT broker configuration
├── jupyter/
│   ├── notebooks/              # Analysis and visualization notebooks
│   │   └── *.ipynb            
│   ├── Dockerfile
│   └── requirements.txt
├── nodered/                    # Node-RED flows
├── rml/
│   ├── rml-control-packets/
│   │   ├── *.ttl               # RML mapping files
│   │   └── *.sh                # Mapping execution scripts
│   └── run.sh                 
├── docker-compose.yml
└── README.md
```

## 5. Installation and Setup

### 5.1 Prerequisites

If you want to use the framework directly, you have to run the project using a [Docker container](https://www.docker.com/). At first you have to download the repository, and then run it.

### 5.2 Downloading the Repository

You can download the repository using one of the following methods:

**HTTPS**
```bash
git clone https://github.com/doernern/MQTT2RDF.git
```

**SSH**
```bash
git clone git@github.com:doernern/MQTT2RDF.git
```

**GitHub CLI**
```bash
gh repo clone doernern/MQTT2RDF
```
Alternatively, download the repository as a ZIP file directly on [GitHub](https://github.com/doernern/MQTT4SSNOntology).   

## 6. Running the Framework

You can start and stop the framework using [Docker](https://www.docker.com/).

### 6.1 Start the Framework

To start:
- EMQX
- Node-RED
- RMLMapper
- GraphDB
- Jupyter Notebook

```bash
docker compose up -d
```

### 6.2 Stop the Framework

To stops all services:

```bash
docker compose down
```

## 7. MQTT Broker (EMQX)

The framework uses [EMQX](https://www.emqx.com) as MQTT broker.

- Management UI: `http://localhost:18083`
- Default credentials: 
	- Username: `admin`
	- Password: `public`

EMQX forwards MQTT events to Node-RED using [Webhooks](https://docs.github.com/en/webhooks).
Default Webhook URL: `http://nodered:1880/emqx/events`
[Webhooks](https://docs.github.com/en/webhooks) are fully adaptable and can be modified for different deployment scenarios or endpoints.

## 8. Capturing MQTT Traffic with Node-RED

- UI: `http://localhost:1880`
- The EMQX Flow is provided as part of the framework.
- An HTTP node listens on the endpoint: `/emqx/events`

This endpoint receives MQTT event notifications from EMQX [Webhooks](https://docs.github.com/en/webhooks).
Webhooks and flows can be adapted for different use cases and message formats.

## 9. RDF Mapping

9.1 RML Mappings

- For each MQTT control packet type it exists:
	- A dedicated RML mapping file (rml/rml-control-packets/*.ttl)
	- A corresponding shell script (rml/rml-control-packets/*.sh)
- Mappings rely on:
	- [MQTT4SSN ontology](https://www.w3id.org/MQTT4SSN-Ontology/)
	- [SOSA vocabulary](https://www.w3.org/TR/vocab-ssn/)
	
9.2. Mapping Execution

The shell scripts:
1. Monitor the Node-RED export directory.
2. Invoke the RMLMapper.
3. Generate RDF triples in Turtle format.
4. Upload triples to GraphDB.
5. Clean up temporary files.
