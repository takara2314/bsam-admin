import { parse } from 'https://deno.land/std@0.224.0/flags/mod.ts';

const flags = parse(Deno.args);

async function replaceTemplateValues(
  templatePath: string,
  outputPath: string,
  replacements: Record<string, string>,
) {
  try {
    let content = await Deno.readTextFile(templatePath);
    for (const [key, value] of Object.entries(replacements)) {
      content = content.replace(new RegExp(`\\$\{${key}\}`, 'g'), value);
    }
    await Deno.writeTextFile(outputPath, content);
    console.log(`${outputPath} has been created.`);
  } catch (error) {
    console.error(`An error occurred while creating ${outputPath}:`, error);
  }
}

async function main() {
  const replacements = {
    FIREBASE_ANDROID_API_KEY: flags.FIREBASE_ANDROID_API_KEY,
    FIREBASE_IOS_API_KEY: flags.FIREBASE_IOS_API_KEY,
  };

  const templates = [
    {
      template: '.github/templates/firebase_options.dart',
      output: 'lib/firebase_options.dart',
    },
    {
      template: '.github/templates/google-services.json',
      output: 'android/app/google-services.json',
    },
    {
      template: '.github/templates/GoogleService-Info.plist',
      output: 'ios/Runner/GoogleService-Info.plist',
    },
  ];

  for (const { template, output } of templates) {
    await replaceTemplateValues(template, output, replacements);
  }
}

main().catch((error) => {
  console.error('An error occurred:', error);
});
