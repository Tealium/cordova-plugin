#!/usr/bin/env node
'use strict';

const fs = require('fs');
const path = require('path');

const plugins = ['kotlin-android-extensions'];

module.exports = function () {
  const file = path.join('platforms', 'android', 'app', 'build.gradle');

  if (fs.existsSync(file)) {
    let newFile = fs.readFileSync(file).toString();

    console.log('Removing lines from build.gradle... ');

    newFile = removeRegExp(newFile, plugins, applyPluginRegExp);

    fs.writeFileSync(file, newFile);
  } else {
    throw `Couldn't find file: ${file}`;
  }
};

function removeRegExp(file, items, regExp) {
  const lines = [];

  for (const item of items) {
    lines.push(...Array.from(file.matchAll(regExp(item))));
  }

  if (lines.length > 0) {
    lines.sort((a, b) => b.index - a.index);

    for (const line of lines) {
      console.log(`Removing line from build.gradle: ${line[0].trim()}`);

      file = file.slice(0, line.index) + file.slice(line.index + line[0].length);
    }
  }

  return file;
}

function applyPluginRegExp(plugin) {
  return new RegExp("\\s*?apply plugin: '" + plugin + "'.*?", 'gm');
}