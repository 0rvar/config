#!/usr/bin/env -S deno run

import { readLines } from 'https://deno.land/std@0.76.0/io/bufio.ts';

var args: Array<string> = Deno.args;
var input = args[0];

var stdin = Deno.stdin;
var isTTY = Deno.isatty(stdin.rid);

if (isTTY && args.length === 0) {
  console.error('Pipe stdin or pass a file');
} else if (isTTY && args.length !== 0) {
  const fileReader = await Deno.open(input);
  processFile(fileReader);
} else {
  processFile(stdin);
}

async function processFile(handle: Deno.Reader) {
  const fileOccurrences: Record<string, number> = {};
  const files: Array<string> = [];
  for await (const line of readLines(handle)) {
    const match = line.match(/^([^ ]+\.(tsx?|jsx?))/i);
    if (match) {
      const fileName = match[1];
      if (fileOccurrences[fileName] == null) {
        files.push(fileName);
      }
      fileOccurrences[fileName] = (fileOccurrences[fileName] || 0) + 1;
    }
  }
  files.sort((a, b) => fileOccurrences[a] - fileOccurrences[b]);
  files.forEach((fileName) => {
    console.log(`${fileName}: ${fileOccurrences[fileName]} errors`);
  });
  const totalNumberOfErrors = files.reduce(
    (sum, fileName) => sum + fileOccurrences[fileName],
    0
  );
  console.log();
  console.log(`Total: ${totalNumberOfErrors} errors in ${files.length} files`);
}
