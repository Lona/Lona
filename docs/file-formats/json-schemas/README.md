# JSON Schemas

To understand the structure of JSON files, we use JSON schemas. JSON schemas describe the shape of the JSON file, as well as value sets, default values, and descriptions.

If you use [VS Code](https://code.visualstudio.com), you can map a JSON file to a schema to have it show some validation feedback and the description of the different fields on hover.

Update your configuration to add the following:

```json
"json.schemas": [
    {
        "fileMatch": [
            "colors.json"
        ],
        "url": "https://raw.githubusercontent.com/airbnb/Lona/master/docs/file-formats/json-schemas/.generated/colors.json"
    }
]
```

## Authoring

The source of truth for the documentation (markdown files) and the JSON schemas is the YAML files in this directory. YAML is a lot easier to edit, especially for multilines strings.

To generate the JSON schema and the Markdown documentation, run the following:

```bash
cd docs/files-formats/json-schemas
./generate.sh colors.yml
```

You can also watch the file and rebuild the schema and documentation when there is a change:

```bash
cd docs/files-formats/json-schemas
./watch.sh colors.yml
```
