ag-relation-resolver
========

[![Build Status](http://img.shields.io/travis/AppGyver/ag-relation-resolver/master.svg)](https://travis-ci.org/AppGyver/ag-relation-resolver)
[![NPM version](http://img.shields.io/npm/v/ag-relation-resolver.svg)](https://www.npmjs.org/package/ag-relation-resolver)
[![Dependency Status](http://img.shields.io/david/AppGyver/ag-relation-resolver.svg)](https://david-dm.org/AppGyver/ag-relation-resolver)
[![Coverage Status](https://img.shields.io/coveralls/AppGyver/ag-relation-resolver.svg)](https://coveralls.io/r/AppGyver/ag-relation-resolver)

# Usage:

Relation resolver basically can do two things:

## Replace collection contents directly

```coffee
RelationResolver = require('ag-relation-resolver')()
RelationResolver.prepare(resourceSchema, dataArray, populateCollectionWithValues=true).then (populatedDataArray)->
    console.log("Array with populated relation values:", populatedDataArray)
```

## Load relation datas into a cache without replacing collection contents for faster rendering later

```coffee
MyModule = angular.module('MyModule', [
    require('ag-relation-resolver')(angular)
])
MyModule.controller (RelationResolver) ->
    RelationResolver.prepare(resourceSchema, dataArray, populateCollectionWithValues=false).then ->
```

render with directives like:

```html
<field-user ng-if="value && displayType == 'user'" user-id="value"></field-user>
<field-relation ng-if="value && displayType == 'relation'" schema="fieldSchema" data="value"></field-relation>
<field-multi-relation ng-if="value && displayType == 'multirelation'" schema="fieldSchema" data="value"></field-multi-relation>
```
