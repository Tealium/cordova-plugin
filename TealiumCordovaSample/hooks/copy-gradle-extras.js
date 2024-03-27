#!/usr/bin/env node
'use strict';

const fs = require('fs');
const path = require('path');


module.exports = function () {
  const sourceFile = path.join('build-extras.gradle');
  const destinationFile = path.join('platforms', 'android', 'app', 'build-extras.gradle');

  if (fs.existsSync(sourceFile)) {
    fs.copyFile(sourceFile, destinationFile, (err) => {
      if (err) throw err;
      console.log('build-extras.gradle was copied.');
    });
  }
};