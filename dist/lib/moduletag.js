var Q, fileTag, moduleTag, path, pkgInfo, strLeft, strRight, walkup;

path = require('path');

strRight = require("underscore.string/strRight");

strLeft = require("underscore.string/strLeft");

pkgInfo = require("pkginfo-async");

walkup = require("node-walkup");

Q = require('q');

fileTag = function(mod, pkg) {
  var baseName, basePath, dir, filename, tag;
  filename = mod.filename || mod.id;
  basePath = pkg.dirname;
  dir = path.dirname(filename);
  baseName = path.parse(filename).name;
  tag = path.join(dir, baseName);
  tag = strRight(tag, basePath);
  tag = strRight(tag, '/');
  return tag;
};

moduleTag = function(mod, cb) {
  var dir;
  if (typeof mod !== "string") {
    dir = path.dirname(mod.filename || mod.id);
  }
  return walkup("package.json", {
    cwd: dir
  }).then(function(matches) {
    var all, m;
    all = (function() {
      var _i, _len, _results;
      _results = [];
      for (_i = 0, _len = matches.length; _i < _len; _i++) {
        m = matches[_i];
        _results.push(pkgInfo(m.dir));
      }
      return _results;
    })();
    return Q.all(all);
  }).then(function(all) {
    var names, p, suffix, tag;
    suffix = fileTag(mod, all[0]);
    names = (function() {
      var _i, _len, _ref, _results;
      _ref = all.reverse();
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        p = _ref[_i];
        _results.push(p.name);
      }
      return _results;
    })();
    tag = names.join("/");
    tag += ":" + suffix;
    if (cb != null) {
      cb(null, tag);
    }
    return tag;
  }).fail(function(err) {
    if (cb != null) {
      cb(err);
    }
    throw err;
  });
};

moduleTag.fileTag = fileTag;

module.exports = moduleTag;
