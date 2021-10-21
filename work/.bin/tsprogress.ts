#!/usr/bin/env -S deno run --allow-run --allow-read

const allFiles = new TextDecoder()
  .decode(
    await Deno.run({
      cmd: ['git', 'ls-files'],
      stdout: 'piped',
    }).output()
  )
  .trim()
  .split('\n');

const tsFiles = allFiles.filter((f) => f.toLocaleLowerCase().endsWith('.ts'));
const jsFiles = allFiles.filter((f) => f.toLocaleLowerCase().endsWith('.js'));

function processFiles(fileNames: Array<string>) {
  const files = fileNames
    .map((fileName) => {
      try {
        const contents = Deno.readTextFileSync(fileName);
        const numLines = contents.split('\n').length;
        const numWords = contents.split(' ').length;
        const numChars = contents.length;
        return {
          fileName,
          numLines,
          numWords,
          numChars,
        };
      } catch (e) {
        return null;
      }
    })
    .filter(notNull);
  const totalLines = files.reduce((acc, curr) => acc + curr.numLines, 0);
  const totalWords = files.reduce((acc, curr) => acc + curr.numWords, 0);
  const totalChars = files.reduce((acc, curr) => acc + curr.numChars, 0);
  return {
    files,
    totalLines,
    totalWords,
    totalChars,
  };
}

const ts = processFiles(tsFiles);
const js = processFiles(jsFiles);

const numTotalFiles = ts.files.length + js.files.length;
const numTotalLines = ts.totalLines + js.totalLines;
const numTotalWords = ts.totalWords + js.totalWords;
const numTotalChars = ts.totalChars + js.totalChars;

const perc = (part: number, total: number) => ((part * 100) / total).toFixed(2);
console.log(
  `.ts files: ${ts.files.length} of ${numTotalFiles} (${perc(
    ts.files.length,
    numTotalFiles
  )}%)`
);
console.log(
  `.ts lines: ${ts.totalLines} of ${numTotalLines} (${perc(
    ts.totalLines,
    numTotalLines
  )}%)`
);
console.log(
  `.ts words: ${ts.totalWords} of ${numTotalWords} (${perc(
    ts.totalWords,
    numTotalWords
  )}%)`
);
console.log(
  `.ts chars: ${ts.totalChars} of ${numTotalChars} (${perc(
    ts.totalChars,
    numTotalChars
  )}%)`
);
console.log();
console.log(
  `.js files: ${js.files.length} of ${numTotalFiles} (${perc(
    js.files.length,
    numTotalFiles
  )}%)`
);
console.log(
  `.js lines: ${js.totalLines} of ${numTotalLines} (${perc(
    js.totalLines,
    numTotalLines
  )}%)`
);
console.log(
  `.js words: ${js.totalWords} of ${numTotalWords} (${perc(
    js.totalWords,
    numTotalWords
  )}%)`
);
console.log(
  `.js chars: ${js.totalChars} of ${numTotalChars} (${perc(
    js.totalChars,
    numTotalChars
  )}%)`
);

console.log();

const notMuchLeft = js.files.length < 50;
const numLargestFiles = notMuchLeft ? js.files.length : 10;

const largestJsFiles = js.files
  .sort((a, b) => b.numLines - a.numLines)
  .slice(0, numLargestFiles);
console.log('Largest js files by lines:');
largestJsFiles.forEach((f) =>
  console.log(`* ${f.fileName} (${f.numLines} lines)`)
);

if (!notMuchLeft) {
  console.log();
  console.log('Smallest non-flowed files by lines:');
  const smallestJsFiles = js.files
    .sort((a, b) => a.numLines - b.numLines)
    .slice(0, 10);
  smallestJsFiles.forEach((f) =>
    console.log(`* ${f.fileName} (${f.numLines} lines)`)
  );
}

function notNull<T extends string | number | boolean | object>(
  item: T | null | undefined
): item is T {
  return item != null;
}
