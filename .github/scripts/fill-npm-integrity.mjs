import { execFileSync } from "node:child_process";
import { readFileSync, writeFileSync } from "node:fs";

const lockfilePath = process.argv[2];
if (!lockfilePath) throw new Error("Usage: node fill-npm-integrity.mjs <package-lock.json>");

const lockfile = JSON.parse(readFileSync(lockfilePath, "utf8"));
for (const [path, entry] of Object.entries(lockfile.packages)) {
  if (!path || entry.link || entry.integrity) continue;
  if (!entry.resolved || !entry.version) {
    throw new Error(`${path} has no integrity and cannot be looked up in npm`);
  }

  const name = path.split("node_modules/").at(-1);
  const dist = JSON.parse(
    execFileSync("npm", ["view", "--json", `${name}@${entry.version}`, "dist"], {
      encoding: "utf8",
    }),
  );
  if (!dist.integrity || dist.tarball !== entry.resolved) {
    throw new Error(`${path} has no matching npm tarball integrity`);
  }
  entry.integrity = dist.integrity;
  console.log(`Filled npm integrity for ${path}`);
}

writeFileSync(lockfilePath, `${JSON.stringify(lockfile, null, 2)}\n`);
