path = require 'path'
_ = require "underscore"
strRight = require "underscore.string/strRight"
strLeft = require "underscore.string/strLeft"
pkgInfo = require "pkginfo-async"
walkup = require "node-walkup"
Q = require 'q'

# Public: Creates a `tag` for a package file as a path fragment from the
#  package base dir
#
#       <filetag> ::= <relative path to module>/<filename without ext>
#
# * `mod`  The file/module for which to create the tag (Object|String)
# * `pkg ` Package info from `pkginfo-async` for the package containing the above module
#
# Returns The filetag as a String
fileTag = ( mod, pkg ) ->
  filename = mod.filename or mod.id
  basePath = pkg.dirname
  dir = path.dirname filename
  baseName = path.parse( filename ).name
  tag = path.join dir, baseName
  tag = strRight tag, basePath
  tag = strRight tag, '/'
  tag

# Public: Creates a `moduletag` for a file/module in a package.
#     The format for a module tag is:
#
#       <moduletag> ::= <package path>:<filetag>
#   where `<package path>` is forward-slash separated
#   string of the file's package, and any other packages
#   up the directory tree, e.g. for when the package is
#   installed as a dependency of another package
#
# * `mod` The file/module to create the tag for as {Object|String}
# * `cb ` Optional callback as {Function}
#
# Returns a promise which resolves to the `moduletag`
moduleTag = ( mod, cb ) ->

  # If we received a nodejs module, get the module's filename or id.
  # Otherwise, we should have received filename as a string.
  # Get the directory from the filename
  dir = path.dirname( mod.filename or mod.id ) unless typeof mod is "string"

  # Walk up the dir tree from the file's directory and
  # find `package.json` information for its enclosing packages
  walkup "package.json", cwd : dir
  .then ( matches ) ->
    all = for m in matches
      pkgInfo m.dir
    Q.all all
  .then ( all ) ->

    # the first part of the `moduletag` is the `<package path>`
    names = for p in all.reverse()
      p.name
    tag = names.join "/"

    # the second part of the `moduletag` is the `<file tag>`
    suffix = fileTag mod, all[ 0 ]
    tag += ":#{suffix}"
    cb null, tag if cb?
    tag
  .fail ( err ) ->
    cb err if cb?
    throw err

moduleTag.fileTag = fileTag

module.exports = moduleTag
