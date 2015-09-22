require('chai').should()

RelationResolver = require '../src/RelationResolver'

describe 'ag-relation-resolver', ->
  describe 'RelationResolver', ->
    it 'is a class', ->
      RelationResolver.should.be.a 'function'

    it 'can be newed without arguments', ->
      new RelationResolver

    describe 'prepare()', ->
      it 'is a function', ->
        (new RelationResolver).prepare.should.be.a 'function'
