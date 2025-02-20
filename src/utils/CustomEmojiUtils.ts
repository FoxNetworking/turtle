import { readFile } from 'fs/promises';

let globalEmojiList: string[] = [];

export async function updateGlobalEmojiList(): Promise<void> {
  const oldListLength = globalEmojiList.length;
  const fileContents = (await readFile(process.env.GLOBAL_EMOJIS_PATH || './data/globalEmojis.json')).toString().trim();
  try {
    JSON.parse(fileContents);
  } catch {
    console.log(`Global emoji list parsing failed. Skipping update.`);
    return;
  }
  globalEmojiList = JSON.parse(fileContents);
  if (oldListLength !== globalEmojiList.length) {
    console.log(`Global emoji list updated. New count: ${globalEmojiList.length}`);
  }
}

export function inputContainsValidEmoji(input: string, additionalEmojis?: string[]): boolean {
  return [...globalEmojiList, ...(additionalEmojis ? additionalEmojis : [])].some((emoji) => input.includes(emoji));
}

export function inputEqualsValidEmoji(input: string, additionalEmojis?: string[]): boolean {
  return [...globalEmojiList, ...(additionalEmojis ? additionalEmojis : [])].some((emoji) => input === emoji);
}

setInterval(async () => {
  await updateGlobalEmojiList();
}, 15 * 1000);
