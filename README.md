# Generic Tagging JSON API

We will be building a Generic Tagging JSON API that can store, retrieve, delete and report on the usage of a "tag" across different entities. This is a guide for the endpoints, if you think you have a better route or would like to modify the naming/schema feel free.

### Create an Entry

```
POST /tag

- Entity Type, e.g. 'Product', 'Article'
- Entity Identifier, e.g. '1234', '582b5530-6cdb-11e4-9803-0800200c9a66'
- Tags, e.g. ['Large', 'Pink', 'Bike']

If the entity already exists it should replace it and all tags, not append to it
```

### Retrieve an Entry

```
GET /tags/:entity_type/:entity_id

- should return a JSON representation of the entity and the tags it has assigned
```

### Remove an Entry

```
DELETE /tags/:entity_type/:entity_id

Completely removes the entity and tags
```

### Retrieve Stats about all Tags

```
GET /stats

Retrives statistics about all tags

e.g. [{tag: 'Bike', count: 5}, {tag: 'Pink', count: 3}]
```

### Retrieve Stats about a specific Entity

```
GET /stats/:entity_type/:entity_id

Retrives statistics about a specific tagged entity
```
