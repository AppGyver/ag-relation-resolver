require('chai').should()

describe "ag-relation-resolver root", ->
  it "should be defined", ->
    require('../src').should.exist