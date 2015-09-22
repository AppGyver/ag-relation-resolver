arrays = require './arrays'

module.exports = _RelationResolver = ->
  @data = {}

  RELATION_DISPLAY_TYPES = ["user", "relation", "multirelation"]

  # get all related model datas in one query
  getRelated = (resourceName, ids) ->
    [fn, query] = if resourceName is "users"
      [supersonic.auth.users, JSON.stringify
        id:
          $in: ids
      ]
    else
      [supersonic.data.model(resourceName), JSON.stringify
        _id:
          $in: ids
      ]

    fn.findAll query: query

  # return all fields of resource with given displayType
  getFieldsWithDisplayType = (displayType, schema) ->
    userFields = Object.keys(schema.fields)
      .map (fieldName) ->
        return schema.fields[fieldName] if schema.fields[fieldName].display_type is displayType
      .filter (item) ->
        return item?

  @prepareRelatedUsers = (schema, collection) =>
    ids = []
    getFieldsWithDisplayType("user", schema)
      .forEach (field) ->
        ids = ids.concat collection
          .filter (item) -> item[field.key]?
          .map (item) -> item[field.key]

    return supersonic.internal.Promise.resolve([]) unless ids.length
    getRelated "users", arrays.unique(ids)
      .then (users) =>
        @data["user"] = {}
        users.forEach (user) =>
          @data["user"][user.id] = user

  @prepareRelatedOneToOne = (schema, collection) ->
    relatedResources = {}
    getFieldsWithDisplayType("relation", schema)
      .forEach (field) ->
        resourceName = field.metadata.collection
        titleKey = field.metadata.collection_field
        relatedResources[resourceName] = {ids: []} unless relatedResources[resourceName]?
        relatedResources[resourceName].ids = relatedResources[resourceName].ids.concat collection
          .filter (item) -> item[field.key]?
          .map (item) -> item[field.key]

        relatedResources[resourceName].ids = arrays.unique(relatedResources[resourceName].ids)

    supersonic.internal.Promise.resolve(relatedResources)

  @prepareRelatedOneToMany = (schema, collection) ->
    relatedResources = {}
    getFieldsWithDisplayType("multirelation", schema)
      .forEach (field) ->
        resourceName = field.metadata.collection
        titleKey = field.metadata.collection_field
        relatedResources[resourceName] = {ids: []} unless relatedResources[resourceName]?
        idArrays = collection
          .filter (item) -> item[field.key]?
          .map (item) ->
            JSON.parse item[field.key]

        relatedResources[resourceName].ids = arrays.unique relatedResources[resourceName].ids.concat(arrays.flatten(idArrays))

    supersonic.internal.Promise.resolve(relatedResources)

  @combineRequiredRelations = (relatedOneToOne, relatedOneToMany) ->
    combinedRelatedResources = {}
    Object.keys(relatedOneToOne).concat(Object.keys(relatedOneToMany))
      .forEach (resourceName) ->
        combinedRelatedResources[resourceName] = {ids: []}
        oneToOneIds = if relatedOneToOne[resourceName]? then relatedOneToOne[resourceName].ids else []
        oneToManyIds = if relatedOneToMany[resourceName]? then relatedOneToMany[resourceName].ids else []
        combinedRelatedResources[resourceName].ids = arrays.unique(oneToOneIds.concat(oneToManyIds))

    promises = Object.keys(combinedRelatedResources).map (resourceName) =>
      getRelated resourceName, combinedRelatedResources[resourceName].ids
        .then (entries) =>
          @data[resourceName] = {}
          entries.forEach (entry) =>
            @data[resourceName][entry.id] = entry

    supersonic.internal.Promise.all promises

  @isRelationField = (schema, field) ->
    schema.fields[field].display_type in RELATION_DISPLAY_TYPES

  @populateCollection = (schema, collection) ->
    fieldArrays = RELATION_DISPLAY_TYPES.map (displayType) -> getFieldsWithDisplayType(displayType, schema)
    arrays
      .flatten(fieldArrays)
      .forEach (field) =>
        collection.forEach (item) =>
          item[field.key] = switch field.display_type
            when "user" then @getUserDisplayValue(item[field.key])
            when "relation" then @getRelationDisplayValue(field, item[field.key])
            when "multirelation" then @getMultiRelationDisplayValue(field, item[field.key])
            else item[field.key]
    collection

  @prepare = (schema, collection, populateCollectionWithValues=true) ->
    @prepareRelatedUsers(schema, collection)
      .then (users) =>
        supersonic.internal.Promise.all [
          @prepareRelatedOneToOne(schema, collection)
          @prepareRelatedOneToMany(schema, collection)
        ]
      .then (result) =>
        [oneToOne, oneToMany] = result
        supersonic.internal.Promise.all @combineRequiredRelations(oneToOne, oneToMany)
      .then =>
        if populateCollectionWithValues
          @populateCollection(schema, collection)
        else
          collection
      .catch (err) ->
        console.log "Something went wrong with relation resolver:", err


  @getUserDisplayValue = (id) ->
    return unless id?
    user = @data["user"][id]
    user.metadata?.name ? user.username

  @getRelationDisplayValue = (fieldSchema, data) ->
    unless data?
      console.log "Skipping getting field value, identifier given was:", data
      return
    unless @data[fieldSchema.metadata.collection][data]?
      console.log "Could not get entry for #{fieldSchema.metadata.collection}.#{fieldSchema.metadata.collection_field} using identifier:", data
      return
    unless @data[fieldSchema.metadata.collection][data][fieldSchema.metadata.collection_field]?
      console.log "Could not get field value for #{fieldSchema.metadata.collection}:#{fieldSchema.metadata.collection_field} using identifier:", data
      return
    @data[fieldSchema.metadata.collection][data][fieldSchema.metadata.collection_field]

  @getMultiRelationDisplayValue = (fieldSchema, data) ->
    return unless data?
    arrayOfIds = try
      angular.fromJson data
    catch error
      console.log "Could not parse multi relation field value:", data
      []

    arrayOfIds
      .map (id) =>
        if @data[fieldSchema.metadata.collection][id]?
          @data[fieldSchema.metadata.collection][id][fieldSchema.metadata.collection_field]
        else
          "« #{fieldSchema.metadata.collection}:#{id} not found »"
      .join(", ")
  @
