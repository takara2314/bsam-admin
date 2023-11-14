import { parse } from 'https://deno.land/std/flags/mod.ts';

const flags = parse(Deno.args);

let content = '';
for (const key in flags) {
  content += `${key}=${flags[key]}\n`;
}

Deno.writeTextFile('.env', content)
  .then(() => {
    console.log('.env file has been created.');
  })
  .catch((err) => {
    console.error(err);
  });
