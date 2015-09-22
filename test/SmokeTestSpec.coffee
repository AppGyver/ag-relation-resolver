require('chai').should()

createRelationResolver = require('../src')

describe "ag-relation-resolver root", ->
  it "should be defined", ->
    createRelationResolver.should.exist

  it "is a function", ->
    createRelationResolver.should.be.a 'function'

  it 'creates a relation resolver when called without arguments', ->
    createRelationResolver().should.have.property('prepare').be.a 'function'

  it.skip 'creates an angular module and returns the module name when called with angular as an argument', ->
    createRelationResolver(angular).should.be.a 'string'
