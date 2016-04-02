should = require( "should" )
assert = require( "assert" )
moduleTag = require( '../index' )

describe "moduletag", ->

  it "create module tag", ( done ) ->
    moduleTag module, ( err, tag ) ->
      tag.should.equal "moduletag:test/moduletag.test"
      done()

  it "returns a promise", ( done ) ->
    moduleTag module
    .then ( tag ) ->
      tag.should.equal "moduletag:test/moduletag.test"
      done()
    .fail done


