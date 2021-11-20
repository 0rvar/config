#!/usr/bin/env -S deno run --allow-run --allow-read

import { parse, print } from 'https://x.nest.land/swc@0.1.4/mod.ts';
import * as types from 'https://x.nest.land/swc@0.1.4/types/options.ts';

const code = `const x: string = "Hello, Deno SWC!"`;

const ast = parse(code, {
  target: 'es2019',
  syntax: 'typescript',
  comments: false,
});

function traverseSwc(
  ast: types.Program | types.ModuleItem | types.Statement | types.Expression
) {
  if (ast.type === 'Module' || ast.type === 'Script') {
    ast.body.forEach((item) => traverseSwc(item));
  } else if (ast.type === '')
}
