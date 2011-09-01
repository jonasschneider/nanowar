var fs      = require('fs'),
    path    = require('path'),
    glob    = require('glob'),
    stdio   = process.binding('stdio')

exports.options = options = {
  verbose:     false,
  directories: ['.']
}

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

function processFile(file, level, already_parsed, moreOptions) {
  var lines = fs.readFileSync(file, 'utf8').split("\n");
  level || (level = 0);
  
  already_parsed || (already_parsed = []);
  
  already_parsed.push(file);
  
  if (options.verbose) {
    stdio.writeError(pad(level) + '> ' + file + '\n');
  }
  
  var firstBodyLine = -1;
  var directiveFound;
  
  var header = ''
  
  lines.forEach(function(line, index, lines) {
    directiveFound = false;
    if(firstBodyLine != -1)
      return
    
    line = line.replace(/^\s*(?:\/\/|\#)=\s*require\s+(["<])([^">]+)([">])\s*$/g, function(match, type, location) {
      directiveFound = true
      
      var resolved = findOne(location, path.extname(file), (type === '<' ? options.directories : [path.dirname(file)]));
      if (resolved) {
        if(already_parsed.indexOf(resolved) == -1)
          return processFile(resolved, level + 1, already_parsed, moreOptions);
        else
          return '';
      } else
        throw new Error('Cannot resolve require:\n\n    ' + match + '\n\n in file ' + file);
        
    });
    
    line = line.replace(/^\s*(?:\/\/|\#)=\s*require_tree\s+([^\s]+)$/g, function(match, dir) {
      directiveFound = true
      
      var matches = glob.globSync(path.join(path.dirname(file), dir, '*'+path.extname(file)))
      
      processed = '';
      
      matches.forEach(function(globbed_file) {
        if(globbed_file != file && already_parsed.indexOf(globbed_file) == -1) {
          var processed_globbed = processFile(globbed_file, level + 1, already_parsed, moreOptions)
          if(processed_globbed.length > 1)
            processed += processed_globbed + "\n"
        }
      })
      
      
      return processed;
    });
    
    if(firstBodyLine == -1 && !directiveFound)
      firstBodyLine = index
    else
      header += line + '\n'
  })
  
  var body = lines.slice(firstBodyLine).join("\n")
  
  if(moreOptions && moreOptions.bodyProcessor)
    body = moreOptions.bodyProcessor(body)
  
  // preserve order, to loaded dependencies go before this file
  already_parsed.splice(already_parsed.indexOf(file), 1)
  already_parsed.push(file)
  
  if(level == 0 && moreOptions && moreOptions.dryRun)
    return already_parsed;
  else
    return header + '\n' + body;
}

exports.processFile = processFile;