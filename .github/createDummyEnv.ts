const contents = {
  'BSAM_SERVER_URL': 'wss://example.com',
  'BSAM_SERVER_TOKEN': 'secret'
}

let content = '';
for (const key in contents) {
  content += `${key}=${contents[key]}\n`;
}

Deno.writeTextFile('.env', content)
  .then(() => {
    console.log('The dummy .env file has been created.');
  })
  .catch((err) => {
    console.error(err);
  });
