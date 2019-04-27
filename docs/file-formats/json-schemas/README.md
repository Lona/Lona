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
        "url": "https://raw.githubusercontent.com/airbnb/Lona/master/docs/file-formats/json-schemas/colors.json"
    }
]
```
