path = require 'path'
strRight = require "underscore.string/strRight"
strLeft = require "underscore.string/strLeft"
pkgInfo = require "pkginfo-async"
walkup = require "node-walkup"
Q = require 'q'

fileTag = ( mod, pkg ) ->
  filename = mod.filename or mod.id
  basePath = pkg.dirname
  dir = path.dirname filename
  baseName = path.parse( filename ).name
  tag = path.join dir, baseName
  tag = strRight tag, basePath
  tag = strRight tag, '/'
  tag

moduleTag = ( mod, cb ) ->
  dir = path.dirname( mod.filename or mod.id ) unless typeof mod is "string"
  walkup "package.json", cwd : dir
  .then ( matches ) ->
    all = for m in matches
      pkgInfo m.dir
    Q.all all
  .then ( all ) ->
    suffix = fileTag mod, all[ 0 ]
    names = for p in all.reverse()
      p.name
    tag = names.join "/"
    tag += ":#{suffix}"
    cb null, tag if cb?
    tag
  .fail ( err ) -> 
    cb err if cb?
    throw err


moduleTag.fileTag = fileTag


module.exports = moduleTag



