require('chai').should()

RelationResolverModule = require '../src/RelationResolverModule'

describe 'ag-relation-resolver', ->
  describe 'RelationResolverModule', ->
    it 'is a function', ->
      RelationResolverModule.should.be.a 'function'

    it.skip 'can be called with angular as an argument', ->
      RelationResolverModule(angular)
