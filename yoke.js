var fs      = require('fs'),
    path    = require('path'),
    glob    = require('glob'),
    stdio   = process.binding('stdio'),
    options = {
      verbose:     false,
      directories: ['.']
    };

var includeFollowing = false;
process.argv.slice(2).forEach(function(option) {
  if (option === '-v' || option === '--verbose') {
    options.verbose = true;
  } else if (option === '-I' || option === '--include') {
    includeFollowing = true;
  } else if (option.indexOf('-I') === 0) {
    options.directories.push(option.substring(2));
  } else if (includeFollowing) {
    options.directories.push(option);
    includeFollowing = false;
  }
});

function findOne(file, extension, directories) {
  var resolved = null;
  directories.forEach(function(directory) {
    if (resolved) {
      return;
    }
    var target = path.join(directory, file + extension);
    if (path.existsSync(target)) {
      resolved = target;
    }
  });
  return resolved;
}

function pad(level) {
  return Array(level * 2 + 1).join(' ');
}

function processFile(file, level, already_parsed) {
  var lines = fs.readFileSync(file, 'utf8');
  level || (level = 0);
  
  already_parsed || (already_parsed = []);
  if(already_parsed.indexOf(file) != -1) return "already";
  already_parsed.push(file);
  
  if (options.verbose) {
    stdio.writeError(pad(level) + '> ' + file + '\n');
  }
  lines = lines.replace(/^\s*\/\/=\s*require\s+(["<])([^">]+).$/mg, function(match, type, location) {
    var resolved = findOne(location, path.extname(file), (type === '<' ? options.directories : [path.dirname(file)]));
    if (resolved) {
      return processFile(resolved, level + 1, already_parsed);
    }
    throw new Error('Cannot resolve require:\n\n    ' + match + '\n\n in file ' + file);
  });
  
  lines = lines.replace(/^\s*\/\/=\s*require_tree\s+([^\s]+)$/mg, function(match, dir) {
    var matches = glob.globSync(path.join(path.dirname(file), dir, '*'+path.extname(file)))
    
    processed = '';
    
    matches.forEach(function(globbed_file) {
      if(globbed_file != file)        
        processed += processFile(globbed_file, level + 1, already_parsed) + "\n\n"
    })
    
    return processed;
  });
  return lines;
}

exports.processFile = processFile;